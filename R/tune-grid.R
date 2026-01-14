#' @importFrom sparklyr tune_grid_spark
#' @export
tune_grid_spark.pyspark_connection <- function(
  sc,
  object,
  preprocessor,
  resamples,
  ...,
  param_info = NULL,
  grid = 10,
  metrics = NULL,
  eval_time = NULL,
  control = tune::control_grid(),
  num_tasks = NULL
) {
  # Makes sure tidymodels packages are installed
  if (!is_installed("tune") | !is_installed("workflows") | !is_installed("rsample")) {
    cli_abort(
      paste(
        "There are missing Tidymodels packages.",
        "Please run {.run install.packages(\"tidymodels\")} and",
        "then try again."
      )
    )
  }

  rpy2_installed()
  call <- rlang::caller_env()
  wf <- workflows::workflow() |>
    workflows::add_model(object) |>
    workflows::add_recipe(preprocessor)

  # ------------------------- Creates `static` object --------------------------
  # This part mostly recreates `tune_grid_loop()` to properly create the
  # `resamples` and `static` objects in order to pass it to the
  # loop_over_all_stages() function that is called inside Spark
  # https://github.com/tidymodels/tune/blob/main/R/tune_grid_loop.R

  wf_metrics <- tune::check_metrics_arg(metrics, wf, call = call)
  param_info <- tune::check_parameters(
    wflow = wf,
    data = resamples$splits[[1]]$data,
    grid_names = names(grid)
  )
  grid <- tune::.check_grid(
    grid = grid,
    workflow = wf,
    pset = param_info
  )

  # Checking for argument values in the `control` that are not supported
  # by this backend
  control_err <- NULL
  if (!is.null(control[["extract"]])) {
    control_err <- "This backend only supports `extract` set to NULL"
  }
  if (isTRUE(control[["save_workflow"]])) {
    control_err <- c(
      control_err,
      "This backend does not support `save_workflow` set to TRUE"
    )
  }
  if (!is.null(control[["backend_options"]])) {
    control_err <- c(
      control_err,
      "This backend only supports `backend_options` set to NULL"
    )
  }
  if (!is.null(control_err)) {
    abort(c(
      "The following incompatability errors in `control` were found:",
      control_err
    ))
  }
  verbose <- control[["verbose"]]
  control <- tune::.update_parallel_over(control, resamples, grid)
  eval_time <- tune::check_eval_time_arg(eval_time, wf_metrics, call = call)
  needed_pkgs <- c(
    "rsample", "workflows", "hardhat", "tune", "reticulate",
    "parsnip", "tailor", "yardstick", "tidymodels",
    workflows::required_pkgs(wf),
    control$pkgs
  ) |>
    unique()
  static <- list(
    wflow = wf,
    param_info = param_info,
    configs = tune::.get_config_key(grid, wf),
    post_estimation = workflows::.workflow_postprocessor_requires_fit(wf),
    metrics = wf_metrics,
    metric_info = tibble::as_tibble(wf_metrics),
    pred_types = tune::.determine_pred_types(wf, wf_metrics),
    eval_time = eval_time,
    split_args = rsample::.get_split_args(resamples),
    control = control,
    pkgs = needed_pkgs,
    strategy = "sequential",
    data = list(fit = NULL, pred = NULL, cal = NULL),
    grid = grid
  )
  if (all(resamples$id == "train/test split")) {
    resamples$.seeds <- map(resamples$id, \(x) integer(0))
  } else {
    # Make and set the worker/process seeds if workers get resamples
    resamples$.seeds <- tune::get_parallel_seeds(nrow(resamples))
  }
  # These are not in tune_grid_loop() but it prepares the variables for the next
  # section
  vec_resamples <- resamples |>
    vctrs::vec_split(by = 1:nrow(resamples)) |>
    _$val
  pasted_pkgs <- paste0("'", needed_pkgs, "'", collapse = ", ")

  # --------------- Prepares and uploads R objects to Spark --------------------
  # Creating unique file names to avoid re-uploading if possible
  hash_static <- rlang::hash(static)
  hash_resamples <- rlang::hash(vec_resamples)

  # Uploads the files to the Spark temp folder, this function skips the upload
  # if the hashed file name has already been uploaded during the current session
  if (verbose) {
    cli_progress_step(
      "Uploading model, pre-processor, and other info to the Spark session"
    )
  }
  spark_session_add_file(static, sc, hash_static)
  if (verbose) {
    cli_progress_step("Uploading the re-samples to the Spark session")
  }
  spark_session_add_file(vec_resamples, sc, hash_resamples)

  # -------------------------- Creates the UDF ---------------------------------
  # Uses the `loop_call` function as the base of the UDF that will be sent to
  # the Spark session. It works by modifying the text of the function, specifically
  # the file names it reads to load the different R object components
  grid_code <- loop_call |>
    deparse() |>
    paste0(collapse = "\n") |>
    str_replace("\"rsample\"", pasted_pkgs) |>
    str_replace("debug <- TRUE", "debug <- FALSE") |>
    str_replace("xy <- 1", "library(tidymodels)") |>
    str_replace("static.rds", path(hash_static, ext = "rds")) |>
    str_replace("resamples.rds", path(hash_resamples, ext = "rds"))

  # -------------------- Creates and uploads the grid  -------------------------
  res_id_df <- purrr::map_df(
    seq_len(length(resamples$id)),
    \(x) data.frame(index = x, id = resamples$id[[x]])
  )
  if (control[["parallel_over"]] == "everything") {
    full_grid <- grid |>
      dplyr::cross_join(res_id_df) |>
      dplyr::arrange("index")
  } else {
    full_grid <- res_id_df
  }

  full_grid <- full_grid |>
    dplyr::select(-"id")

  # The grid is copied to Spark, it will be re-partitioned if `num_tasks`
  # is set. If not set, Spark will decide how many partitions the data will have,
  # that impacts how many discrete jobs there will be set for this run
  if (verbose) {
    cli_progress_step("Copying the grid to the Spark session")
  }
  sc_obj <- spark_session(sc)
  tbl_grid <- sc_obj$createDataFrame(full_grid)
  if (!is.null(num_tasks)) {
    tbl_grid <- tbl_grid$repartition(as.integer(num_tasks))
  }

  # ---------------- Create schema of output from Spark ------------------------
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

  # -------------------- Execute the model tuning in Spark ---------------------
  # The grid is passed to mapInPandas() which will run the resulting code in the
  # Spark session in as many parallel jobs as tbl_grid is partitioned by
  if (verbose) {
    cli_progress_step("Executing the model tuning in Spark")
  }
  tuned_results <- tbl_grid |>
    sa_in_pandas(
      .f = grid_code,
      .schema = cols,
      .as_sdf = FALSE,
    ) |>
    collect()

  # -------------------- Starts building the output object ---------------------
  # Finalizes metrics tables by adding the 'id' label, and `.config`, and
  # restoring the 'dot' prefix to the metric fields (Spark does not like
  # names with dots)
  res <- tuned_results[
    tuned_results$metric != "preds_path" &
      tuned_results$metric != "preds_cols",
  ] |>
    dplyr::rename(
      .metric = "metric",
      .estimator = "estimator",
      .estimate = "estimate",
      .config = "config"
    ) |>
    dplyr::left_join(res_id_df, by = "index") |>
    dplyr::select(-"index") |>
    dplyr::arrange("id")

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
    vctrs::new_data_frame() |> # Removes rsample object's attributes
    dplyr::select(-".seeds")

  # -------------------------- Appends predictions -----------------------------
  if (isTRUE(control[["save_pred"]])) {
    # Gets the column schema spec from a row with a metric name of `pred_cols`.
    # It converts the plain text into a list object
    preds_cols_list <- tuned_results[tuned_results$metric == "preds_cols", ] |>
      dplyr::pull("estimator") |>
      strsplit("\\|") |>
      unlist() |>
      map(strsplit, ":") |>
      map(unlist)

    pred_col_names <- preds_cols_list |>
      map_chr(\(x) x[[1]])

    # Converts the R class to Spark type
    preds_cols <- preds_cols_list |>
      map(\(x) {
        new_type <- x[[2]]
        if (new_type %in% c("character", "factor")) {
          new_type <- "string"
        }
        if (new_type == "numeric") {
          new_type <- "float"
        }
        new_name <- gsub("\\.", "_", x[[1]])
        paste(new_name, new_type)
      }) |>
      reduce(c) |>
      paste(collapse = ", ") |>
      paste(", index integer")

    # From the results, it gets the rows that have the path to the RDS files
    # containing the predictions
    pred_paths <- tuned_results[tuned_results$metric == "preds_path", ] |>
      dplyr::select("index", "estimator") |>
      dplyr::rename(path = "estimator")

    # Runs a Spark job that reads the predictions RDS files from Spark and
    # returns them in a single large table

    fn <- loop_predictions |>
      deparse() |>
      paste0(collapse = "\n")

    pred_results <- pred_paths |>
      sc_obj$createDataFrame() |>
      sa_in_pandas(
        .f = fn,
        .schema = preds_cols,
        .as_sdf = FALSE,
      ) |>
      collect()

    colnames(pred_results) <- c(pred_col_names, "index")

    preds <- pred_results |>
      dplyr::left_join(res_id_df, by = "index") |>
      dplyr::select(-"index") |>
      dplyr::arrange("id")

    preds_map <- map(
      unique(preds$id),
      \(x) preds[preds$id == x, pred_col_names]
    )

    # Appends `.predictions` to the output object
    out <- out |>
      mutate(.predictions = preds_map)
  }

  # ------------------------- Finalizes output object --------------------------
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
  # ----------------- Ensures all needed packages are available ----------------
  needed_pkgs <- c("rsample")
  missing_pkgs <- NULL
  for (pkg in needed_pkgs) {
    if (!rlang::is_installed(pkg)) {
      missing_pkgs <- c(missing_pkgs, pkg)
    }
  }
  if (!is.null(missing_pkgs)) {
    missing_pkgs <- paste0("`", missing_pkgs, "`", collapse = ", ")
    stop("Packages ", missing_pkgs, " are missing")
  }
  xy <- 1
  # ------------------- Reads files with needed R objects ----------------------
  # Loads the needed R objects from disk
  debug <- TRUE
  static_fname <- "static.rds"
  resample_fname <- "resamples.rds"
  if (isFALSE(debug)) {
    pyspark <- reticulate::import("pyspark")
    static_file <- pyspark$SparkFiles$get(static_fname)
    resample_file <- pyspark$SparkFiles$get(resample_fname)
  } else {
    temp_path <- Sys.getenv("TEMP_SPARK_GRID", unset = "~")
    static_file <- file.path(temp_path, static_fname)
    resample_file <- file.path(temp_path, resample_fname)
  }
  static <- readRDS(static_file)
  resamples <- readRDS(resample_file)

  # ------------ Iterates through all the combinations in `x` ------------------
  # Spark will more likely send more than one row (combination) in `x`. It
  # will depend on how the grid data frame was partitioned inside Spark.
  out <- NULL
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
    # ------ Sends current combination to `tune` for processing ----------------
    # TODO: This function check exists because the `tune` version in the Spark
    # cluster may be CRAN. This needs to be removed by the time of release
    if (exists(".loop_over_all_stages", where = "package:tune")) {
      res <- tune::.loop_over_all_stages(curr_resample, curr_grid, static)
    } else {
      res <- tune:::loop_over_all_stages(curr_resample, curr_grid, static)
    }
    # -------------------- Extracts metrics from results -----------------------
    # Mapping function accepts only tables as output, so only the metrics are
    # being sent back instead of the entire results object
    metrics_df <- Reduce(rbind, res$.metrics)
    metrics_df$index <- index
    # ------------------------ Saves predictions -------------------------------
    # If saves_pred is TRUE, the .predictions table is saved in the same
    # directory the initial context and resample objects. There will be one
    # file per permutation. The metrics table will be modified to include the
    # path to the predictions file, and also the column schema of all of the
    # tables
    if (isTRUE(static[["control"]][["save_pred"]])) {
      static_name <- substr(static_fname, 1, nchar(static_fname) - 4)
      resample_name <- substr(resample_fname, 1, nchar(resample_fname) - 4)
      preds_fname <- paste0(resample_name, "-", static_name, "-", index, ".rds")
      if (isTRUE(debug)) {
        base_path <- temp_path
      } else {
        base_path <- pyspark$SparkFiles$getRootDirectory()
      }
      preds <- res$.predictions[[1]]
      preds_file <- file.path(base_path, preds_fname)
      saveRDS(preds, preds_file)
      preds_df <- metrics_df[1, ]
      preds_df$`.estimator` <- preds_file
      preds_df$`.metric` <- "preds_path"
      if (index == 1) {
        cols <- preds |>
          map_chr(class) |>
          imap(\(x, y) paste0(y, ":", x)) |>
          reduce(c) |>
          paste0(collapse = "|")
        preds_cols <- preds_df
        preds_cols$`.estimator` <- cols
        preds_cols$`.metric` <- "preds_cols"
        preds_df <- rbind(preds_cols, preds_df)
      }
      metrics_df <- rbind(preds_df, metrics_df)
    }
    out <- rbind(out, metrics_df)
  }
  out
}

loop_predictions <- function(x) {
  out <- NULL
  for (i in seq_len(nrow(x))) {
    cr <- x[i, ]
    for (j in 1:5) {
      if (file.exists(cr$path)) {
        curr <- readRDS(cr$path)
        curr$index <- cr$index
        out <- rbind(out, curr)
        break()
      } else {
        Sys.sleep(0.1)
      }
    }
  }
  out
}
