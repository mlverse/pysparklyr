#' @export
tune_grid_spark <- function(
  object,
  preprocessor,
  resamples,
  ...,
  param_info = NULL,
  grid = 10,
  metrics = NULL,
  eval_time = NULL,
  control = control_grid(),
  sc,
  grid_partitions = NULL
) {
  call <- rlang::caller_env()
  wf <- workflow() |>
    add_model(object) |>
    add_recipe(preprocessor)

  # This part mostly recreates `tune_grid_loop()` to properly create the
  # `resamples` and `static` objects in order to pass it to the
  # loop_over_all_stages() function that is called inside Spark
  # https://github.com/tidymodels/tune/blob/main/R/tune_grid_loop.R

  wf_metrics <- check_metrics_arg(metrics, wf, call = call)
  param_info <- tune::check_parameters(
    wflow = wf,
    data = resamples$splits[[1]]$data,
    grid_names = names(grid)
  )
  grid <- tune:::check_grid(
    grid = grid,
    workflow = wf,
    pset = param_info
  )
  control <- tune:::update_parallel_over(control, resamples, grid)
  eval_time <- check_eval_time_arg(eval_time, wf_metrics, call = call)
  needed_pkgs <- c(
    "rsample", "workflows", "hardhat", "tune", "reticulate",
    "parsnip", "tailor", "yardstick", "tidymodels",
    required_pkgs(wf),
    control$pkgs
  ) |>
    unique()
  static <- list(
    wflow = wf,
    param_info = param_info,
    configs = tune:::get_config_key(grid, wf),
    post_estimation = workflows::.workflow_postprocessor_requires_fit(wf),
    metrics = wf_metrics,
    metric_info = tibble::as_tibble(wf_metrics),
    pred_types = tune:::determine_pred_types(wf, wf_metrics),
    eval_time = eval_time,
    split_args = rsample::.get_split_args(resamples),
    control = control,
    pkgs = needed_pkgs,
    strategy = "sequential",
    data = list(fit = NULL, pred = NULL, cal = NULL),
    grid = grid
  )
  if (all(resamples$id == "train/test split")) {
    resamples$.seeds <- purrr::map(resamples$id, \(x) integer(0))
  } else {
    # Make and set the worker/process seeds if workers get resamples
    resamples$.seeds <- get_parallel_seeds(nrow(resamples))
  }
  # These are not in tune_grid_loop() but it prepares the variables for the next
  # section
  vec_resamples <- resamples |>
    vctrs::vec_split(by = 1:nrow(resamples)) |>
    _$val
  pasted_pkgs <- paste0("'", needed_pkgs, "'", collapse = ", ")

  # Creating unique file names to avoid re-uploading if possible
  hash_static <- rlang::hash(static)
  hash_resamples <- rlang::hash(vec_resamples)

  # Uploads the files to the Spark temp folder, this function skips the upload
  # if the hashed file name has already been uploaded during the current session
  spark_session_add_file(static, sc, hash_static)
  spark_session_add_file(vec_resamples, sc, hash_resamples)

  # Uses the `loop_call` function as the base of the UDF that will be sent to
  # the Spark session. It works by modifying the text of the function, specifically
  # the file names it reads to load the different R object components
  grid_code <- paste0(deparse(loop_call), collapse = "\n")
  grid_code <- gsub("\"rsample\"", pasted_pkgs, grid_code)
  grid_code <- sub("static.rds", path(hash_static, ext = "rds"), grid_code)
  grid_code <- sub("resamples.rds", path(hash_resamples, ext = "rds"), grid_code)

  # Creating the tune grid data frame
  res_id_df <- map_df(
    seq_len(length(resamples$id)),
    \(x) data.frame(index = x, id = resamples$id[[x]])
  )
  if (control[["parallel_over"]] == "everything") {
    full_grid <- grid |>
      dplyr::cross_join(res_id_df) |>
      dplyr::arrange(index)
  } else {
    full_grid <- res_id_df
  }

  full_grid <- full_grid |>
    dplyr::select(-id)

  # The pandas mapping function requires all of the output column names
  # and types to be specified. Types have to be converted too
  cols <- imap_chr(
    static$configs[, colnames(static$configs) != ".config"],
    \(x, y) {
      if (inherits(x, "character")) {
        p_class <- "string"
      } else if (inherits(x, "numeric")) {
        p_class <- "float"
      } else {
        p_class <- class(x)
      }
      paste0(y, " ", p_class, ",")
    }
  ) |>
    paste0(collapse = " ") |>
    paste(
      "metric string, estimator string, estimate double,",
      "config string, index integer"
    )

  sc_obj <- spark_session(sc)

  # The grid is copied to Spark, it will be repartitioned if `grid_paritions`
  # is set. If not set, Spark will decide how many partitions the data will have,
  # that impacts how many discrete jobs there will be set for this run
  tbl_grid <- sc_obj$createDataFrame(full_grid)
  if (!is.null(grid_partitions)) {
    tbl_grid <- tbl_grid$repartition(as.integer(grid_partitions))
  }
  #              ****** This is where the magic happens ******
  # The grid hs passed mapInPandas() which will run the resulting code in the
  # Spark session in as many parallel jobs as tbl_grid is partitioned by
  tuned_results <- tbl_grid |>
    sa_in_pandas(
      .f = grid_code,
      .schema = cols,
      .as_sdf = FALSE,
    ) |>
    collect()

  # Finalizes metrics tables by adding the 'id' label, and `.config`, and
  # restoring the 'dot' prefix to the metric fields (Spark does not like
  # names with dots)
  res <- tuned_results |>
    dplyr::rename(
      .metric = metric,
      .estimator = estimator,
      .estimate = estimate,
      .config = config
    ) |>
    dplyr::left_join(res_id_df, by = "index") |>
    dplyr::select(-index) |>
    dplyr::arrange(id)

  # Converts metrics to list separated by id's
  res_names <- colnames(res)
  metrics_names <- res_names[res_names != "id"]
  metrics_map <- map(
    unique(res$id),
    \(x) res[res$id == x, metrics_names]
  )

  # Creates dummy 'notes' table
  notes <- list(tibble(
    location = character(0),
    type = character(0),
    note = character(0),
    trace = list()
  ))

  # Joins the resamples, metrics and notes tables, and adds needed attributes
  # to make it a viable tune_results object.
  out <- resamples |>
    as_tibble() |>
    mutate(
      .metrics = metrics_map,
      .notes = notes
    ) |>
    vctrs::new_data_frame() # Removes rsample object's attributes

  tibble::new_tibble(
    x = out,
    nrow = nrow(out),
    parameters = static$param_info,
    metrics = static$metrics,
    eval_time = eval_time,
    eval_time_target = NULL,
    outcomes = tune::outcome_names(wf),
    rset_info = tune::pull_rset_attributes(resamples),
    workflow = wf,
    class = c(class(out), "tune_results")
  )
}

# `x` only contains a table with the grid containing every single combination
loop_call <- function(x) {
  needed_pkgs <- c("rsample")
  missing_pkgs <- NULL
  for (pkg in needed_pkgs) {
    if (!rlang::is_installed(pkg)) {
      missing_pkgs <- c(missing_pkgs, pkg)
    }
  }
  if (!is.null(missing_pkgs)) {
    stop(
      "Packages ",
      paste0("`", missing_pkgs, "`", collapse = ", "),
      " are missing"
    )
  }
  library(tidymodels)
  # ------------------- Updates from caller function section -------------------
  # Loads the needed R objects from disk
  pyspark <- reticulate::import("pyspark")
  static <- readRDS(pyspark$SparkFiles$get("static.rds"))
  resamples <- readRDS(pyspark$SparkFiles$get("resamples.rds"))
  # ----------------------------------------------------------------------------
  out <- NULL
  # Spark will more likely send more than one row (combination) in `x`. It
  # will depend on how the grid data frame was partitioned inside Spark.
  for (i in seq_len(nrow(x))) {
    curr_x <- x[i, ]
    if (static$control$parallel_over == "everything") {
      curr_grid <- curr_x[, colnames(curr_x) != "index"]
      index <- curr_x$index
    } else {
      curr_grid <- static$grid
      index <- curr_x
    }
    curr_resample <- resamples[[index]]
    # loop_over_all_stages() requires the grid to be a tibble
    curr_grid <- tibble::as_tibble(curr_grid)
    assign(".Random.seed", c(1L, 2L, 3L), envir = .GlobalEnv)
    res <- tune:::loop_over_all_stages(curr_resample, curr_grid, static)
    # Extracts the metrics to table and adds them the larger table sent back to
    # the mapping function.
    metrics_df <- Reduce(rbind, res$.metrics)
    metrics_df$index <- index
    out <- rbind(out, metrics_df)
  }
  out
}
