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
  control = control_grid(),
  sc
) {
  wf <- workflow() |>
    add_model(object) |>
    add_recipe(preprocessor)
  metrics <- check_metrics_arg(metrics, wf, call = rlang::caller_env())
  pred_types <- determine_pred_types(wf, metrics)

  # Creating unique file names to avoid re-uploading if possible
  hash_wf <- rlang::hash(wf)
  hash_metrics <- rlang::hash(metrics)
  hash_resamples <- rlang::hash(resamples)
  hash_pred_types <- rlang::hash(pred_types)

  # Uploads the files to the Spark temp folder, this function skips the upload
  # if the hashed file name has already been uploaded during the current session
  spark_session_add_file(wf, sc, hash_wf)
  spark_session_add_file(metrics, sc, hash_metrics)
  spark_session_add_file(resamples, sc, hash_resamples)
  spark_session_add_file(pred_types, sc, hash_pred_types)

  # Uses the `loop_call` function as the base of the UDF that will be sent to
  # the Spark session. It works by modifying the text of the function, specifically
  # the file names it reads to load the different R object components
  root_folder <- spark_session_root_folder(sc)
  grid_code <- paste0(deparse(loop_call), collapse = "\n")
  grid_code <- sub("path/to/root", root_folder, grid_code)
  grid_code <- sub("wf.rds", path(hash_wf, ext = "rds"), grid_code)
  grid_code <- sub("metrics.rds", path(hash_metrics, ext = "rds"), grid_code)
  grid_code <- sub("resamples.rds", path(hash_resamples, ext = "rds"), grid_code)
  grid_code <- sub("pred_types.rds", path(hash_pred_types, ext = "rds"), grid_code)

  # Creating the tune grid data frame
  res_id_df <- map_df(
    seq_len(length(resamples$id)),
    \(x) data.frame(index = x, id = resamples$id[[x]])
  )
  full_grid <- grid |>
    dplyr::cross_join(res_id_df) |>
    dplyr::arrange(index)

  # Copies the grid to the Spark session. This is needed so that
  # spark_apply() can recognize and use the table to set up each
  # iteration
  tbl_grid <- copy_to(
    sc,
    df = full_grid,
    name = "pysparklyrtempgrid",
    overwrite = TRUE
  )

  # The pandas mapping function requires all of the output column names
  # and types to be specified. Types have to be converted too
  cols <- imap_chr(
    grid,
    \(x, y) {
      x_class <- class(x)
      if (x_class == "character") {
        p_class <- "string"
      } else if (x_class == "numeric") {
        p_class <- "double"
      } else {
        p_class <- x_class
      }
      paste0(y, " ", x_class, ",")
    }
  ) |>
    paste0(collapse = " ") |>
    paste("metric string, estimator string, estimate double, index integer")

  # Runs the code against the copies grid
  tuned_results <- tbl_grid |>
    spark_apply(
      f = grid_code,
      columns = cols
    ) |>
    collect()

  # Finalizes metrics tables by adding the 'id' label, and `.config`, and
  # restoring the 'dot' prefix to the metric fields (Spark does not like
  # names with dots)
  tuned_results <- tuned_results |>
    dplyr::rename(
      .metric = metric,
      .estimator = estimator,
      .estimate = estimate
    ) |>
    dplyr::left_join(res_id_df, by = "index") |>
    dplyr::select(-index) |>
    dplyr::left_join(get_config_key(grid, wf), by = colnames(grid)) |>
    dplyr::arrange(.config)

  # Converts metrics to list separated by id's
  res_names <- colnames(tuned_results)
  metrics_names <- res_names[res_names != "id"]
  metrics_map <- map(
    unique(tuned_results$id),
    \(x) tuned_results[tuned_results$id == x, metrics_names]
  ) |>
    set_names(unique(tuned_results$id))

  # Creates dummy 'notes' table
  notes <- list(tibble(
    location = character(0),
    type = character(0),
    note = character(0),
    trace = list()
  ))

  # Joins the resamples, metrics and notes tables, and adds needed attributes
  out <- resamples |>
    as_tibble() |>
    mutate(
      .metrics = metrics_map,
      .notes = notes
    )
  class(out) <- c("tune_results", class(out))
  attr(out, "metrics") <- metrics
  attr(out, "parameters") <- tune::check_parameters(wf)
  out
}

spark_session_root_folder <- function(sc) {
  # A unique GUID is assigned to the Spark connection
  # this is used to pull the root folder only one time. It will save it to
  # a package level environment variable that will be retained while the
  # connection is current.
  connection_id <- sc[["connection_id"]]
  artifacts <- pysparklyr_env[["artifacts"]][[connection_id]]
  if (is.null(artifacts)) {
    py_run_string("
from pyspark.sql.functions import udf
from pyspark.sql.types import StringType
from pyspark import SparkFiles
def get_root_dir(dummy_input):
    root_dir = SparkFiles.getRootDirectory()
    return f'{root_dir}'
root_dir_udf = udf(get_root_dir, StringType())
")
    main <- reticulate::import_main()
    sc_obj <- spark_session(sc)
    temp_df <- sc_obj$createDataFrame(data.frame(a = 1))
    root_df <- temp_df$withColumn("root_folder", main$root_dir_udf("a"))$collect()
    root_folder <- root_df[[1]]$asDict()$root_folder
    artifacts <- list(root_folder = root_folder, files = c())
    pysparklyr_env$artifacts[[connection_id]] <- artifacts
  }
  pysparklyr_env$artifacts[[connection_id]]$root_folder
}

spark_session_add_file <- function(x, sc, file_name = NULL) {
  # Tracks in a environment variable which file names have already been
  # uploaded to avoid doing it again. This is why the hashed values of
  # the object in `x` is preferred, which ensure proper tracking of the
  # actual objects that have been uploaded
  invisible(spark_session_root_folder(sc))
  connection_id <- sc[["connection_id"]]
  artifacts <- pysparklyr_env[["artifacts"]][[connection_id]]
  if (is.null(file_name)) {
    file_name <- rlang::hash(x)
  }
  files <- artifacts[["files"]]
  if (!file_name %in% artifacts[["files"]]) {
    temp_file <- path_temp(file_name, ext = "rds")
    saveRDS(x, temp_file)
    sc_obj <- spark_session(sc)
    sc_obj$addArtifact(temp_file, file = TRUE)
    file_delete(temp_file)
    pysparklyr_env[["artifacts"]][[connection_id]]$files <- c(file_name, files)
  }
  invisible()
}

# `x` only contains a table with the grid containing every single combination
loop_call <- function(x) {
  library(tidymodels)
  # Set this environment variable to develop/debug
  # the function without needing a Spark connection
  root_folder <- Sys.getenv("TEMP_SPARK_GRID")
  if (root_folder == "") {
    root_folder <- "path/to/root"
  }
  # Loads all of the needed R objects from disk
  wf <- readRDS(file.path(root_folder, "wf.rds"))
  metrics <- readRDS(file.path(root_folder, "metrics.rds"))
  resamples <- readRDS(file.path(root_folder, "resamples.rds"))
  pred_types <- readRDS(file.path(root_folder, "pred_types.rds"))

  out <- NULL
  # Spark will more likely send more than one row (combination) in `x`. It
  # will depend on how the grid data frame was partitioned inside Spark.
  for (i in seq_len(nrow(x))) {
    curr_x <- x[i, ]
    resample <- get_rsplit(resamples, curr_x$index)
    # Assumes that the parameters are all but the last to
    # variables in the row currently being processed
    params <- as.list(curr_x[, 1:(length(curr_x) - 2)])
    re_training <- as.data.frame(resample, data = "analysis")
    # Trains the workflow
    fitted_workflow <- wf |>
      finalize_workflow(params) |>
      fit(re_training)
    re_testing <- as.data.frame(resample, data = "assessment")
    # Predictions are run based on the types of output expected by the
    # metrics. This means that the predictions need to run against the
    # trained parsnip object
    trained_model <- hardhat::extract_fit_parsnip(fitted_workflow)
    forged_wf <- forge_from_workflow(re_testing, fitted_workflow)
    outcome_var <- tune::outcome_names(fitted_workflow)
    predictions <- pred_types |>
      map(\(x) predict(trained_model, forged_wf$predictors, type = x)) |>
      bind_cols() |>
      mutate(.truth = re_testing[, outcome_var]) |>
      bind_cols(as.data.frame(params))
    # Uses this internal function in order to output the exact same metric
    # results as a local R session would
    curr <- .estimate_metrics(
      dat = predictions,
      metric = metrics,
      param_names = names(params),
      outcome_name = ".truth",
      metrics_info = metrics_info(metrics),
      event_level = "first" # TODO: replace with what's in `control`
    )
    # Renaming columns because Spark does not like 'dot' prefixes in names
    colnames(curr) <- c(names(params), "metric", "estimator", "estimate")
    curr$index <- curr_x$index
    out <- rbind(out, curr)
  }
  out
}
