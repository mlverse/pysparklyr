# Will need exported:
# - tune:::loop_over_all_stages
# Would be nice if exported:
# - tune:::get_config_key
# - tune:::determine_pred_types

#' @export
spark_tune_grid <- function(
  object,
  preprocessor,
  resamples,
  ...,
  param_info = NULL,
  grid = 10,
  metrics = NULL,
  eval_time = NULL,
  control = control_grid(parallel_over = "everything"),
  sc,
  grid_partitions = NULL
) {
  wf <- workflow() |>
    add_model(object) |>
    add_recipe(preprocessor)
  wf_metrics <- check_metrics_arg(metrics, wf, call = rlang::caller_env())
  param_info <- tune::check_parameters(
    wflow = wf,
    data = resamples$splits[[1]]$data,
    grid_names = names(grid)
  )
  static <- list(
    wflow = wf,
    param_info = param_info,
    configs = tune:::get_config_key(grid, wf),
    post_estimation = workflows::.workflow_postprocessor_requires_fit(wf),
    metrics = wf_metrics,
    metric_info = tibble::as_tibble(wf_metrics),
    pred_types = tune:::determine_pred_types(wf, wf_metrics),
    eval_time = NULL,
    split_args = rsample::.get_split_args(resamples),
    control = control,
    pkgs = "tidymodels",
    strategy = "sequential",
    data = list(fit = NULL, pred = NULL, cal = NULL)
  )
  if (all(resamples$id == "train/test split")) {
    resamples$.seeds <- purrr::map(resamples$id, \(x) integer(0))
  } else {
    # Make and set the worker/process seeds if workers get resamples
    resamples$.seeds <- get_parallel_seeds(nrow(resamples))
  }
  vec_resamples <- vec_list_rowwise(resamples)
  # Creating unique file names to avoid re-uploading if possible
  hash_static <- rlang::hash(static)
  hash_resamples <- rlang::hash(vec_resamples)
  hash_r_seed <- rlang::hash(.Random.seed)

  # Uploads the files to the Spark temp folder, this function skips the upload
  # if the hashed file name has already been uploaded during the current session
  spark_session_add_file(static, sc, hash_static)
  spark_session_add_file(vec_resamples, sc, hash_resamples)
  spark_session_add_file(.Random.seed, sc, hash_r_seed)

  # Uses the `loop_call` function as the base of the UDF that will be sent to
  # the Spark session. It works by modifying the text of the function, specifically
  # the file names it reads to load the different R object components
  root_folder <- spark_session_root_folder(sc)
  grid_code <- paste0(deparse(loop_call), collapse = "\n")
  grid_code <- sub("path/to/root", root_folder, grid_code)
  grid_code <- sub("static.rds", path(hash_static, ext = "rds"), grid_code)
  grid_code <- sub("resamples.rds", path(hash_resamples, ext = "rds"), grid_code)
  grid_code <- sub("r_seed.rds", path(hash_r_seed, ext = "rds"), grid_code)

  # Creating the tune grid data frame
  res_id_df <- map_df(
    seq_len(length(resamples$id)),
    \(x) data.frame(index = x, id = resamples$id[[x]])
  )
  full_grid <- grid |>
    dplyr::cross_join(res_id_df) |>
    dplyr::arrange(index) |>
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
    )
  class(out) <- c("tune_results", class(out))
  attr(out, "metrics") <- static$metrics
  attr(out, "outcomes") <- tune::outcome_names(wf)
  attr(out, "parameters") <- static$param_info
  attr(out, "rset_info") <- tune::pull_rset_attributes(resamples)
  out
}

# `x` only contains a table with the grid containing every single combination
loop_call <- function(x) {
  library(tidymodels)

  # ------------------- Updates from caller function section -------------------
  root_folder <- "path/to/root"
  # This weird check here is to make it easy to debug/develop this function
  if (root_folder == "path/to/root") {
    root_folder <- Sys.getenv("TEMP_SPARK_GRID")
  }
  # Loads the needed R objects from disk
  static <- readRDS(file.path(root_folder, "static.rds"))
  resamples <- readRDS(file.path(root_folder, "resamples.rds"))
  # To match the 'seed' from the caller R seesion
  #assign(".Random.seed", readRDS(file.path(root_folder, "r_seed.rds")))
  # ----------------------------------------------------------------------------
  out <- NULL
  # Spark will more likely send more than one row (combination) in `x`. It
  # will depend on how the grid data frame was partitioned inside Spark.
  for (i in seq_len(nrow(x))) {
    curr_x <- x[i, ]
    curr_resample <- resamples[[curr_x$index]]
    curr_grid <- curr_x[, colnames(curr_x) != "index"]
    # loop_over_all_stages() requires the grid to be a tibble
    curr_grid <- tibble::as_tibble(curr_grid)
    assign(".Random.seed", c(1L, 2L, 3L), envir = .GlobalEnv)
    res <- tune:::loop_over_all_stages(curr_resample, curr_grid, static)
    # Extracts the metrics to table and adds them the larger table sent back to
    # the mapping function.
    metrics_df <- Reduce(rbind, res$.metrics)
    metrics_df$index <- curr_x$index
    out <- rbind(out, metrics_df)
  }
  out
}

vec_list_rowwise <- function(x) {
  vctrs::vec_split(x, by = 1:nrow(x))$val
}
