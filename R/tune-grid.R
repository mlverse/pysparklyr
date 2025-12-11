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
  # Get the location in the Spark driver where the files will be
  # temporarily uploaded to
  root_folder <- spark_session_root_folder(sc)

  # Hashing R objects one time and using it for both the upload and
  # reading inside the UDF script. This is done to avoid uploading the
  # same files over and over again during the Spark session
  hash_preprocessor <- rlang::hash(preprocessor)
  hash_model <- rlang::hash(object)
  hash_resamples <- rlang::hash(resamples)

  # Copying R objects to Spark session
  spark_session_add_file(preprocessor, sc, hash_preprocessor)
  spark_session_add_file(object, sc, hash_model)
  spark_session_add_file(resamples, sc, hash_resamples)

  # De-parsing the code and updating the file and folder references
  grid_code <- paste0(deparse(loop_call), collapse = "\n")
  grid_code <- sub("preprocessing.rds", path(hash_preprocessor, ext = "rds"), grid_code)
  grid_code <- sub("model.rds", path(hash_model, ext = "rds"), grid_code)
  grid_code <- sub("resamples.rds", path(hash_resamples, ext = "rds"), grid_code)
  grid_code <- sub("path/to/root", root_folder, grid_code)

  # Creating the tune grid data frame
  full_grid <- data.frame()
  for (i in seq_along(resamples$splits)) {
    temp_grid <- grid
    temp_grid$index <- i
    temp_grid$id <- resamples$id[[i]]
    full_grid <- rbind(full_grid, temp_grid)
  }

  # Copies the grid to the Spark session. This is needed so that
  # spark_apply() can recognize and use the table to set up each
  # iteration
  tbl_grid <- copy_to(
    sc,
    df = full_grid,
    name = "pysparklyrtempgrid",
    overwrite = TRUE
  )

  cols <- paste0(
    "num_comp integer, tree_depth integer, metric string,",
    " estimator string, estimate double, id string"
  )

  # Runs the code against the copies grid
  tuned_results <- tbl_grid |>
    spark_apply(
      f = grid_code,
      columns = cols
    ) |>
    collect()

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

  resamples |>
    mutate(
      .metrics = metrics_map,
      .notes = notes
    )
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
  pre_processing <- readRDS(file.path(root_folder, "preprocessing.rds"))
  model <- readRDS(file.path(root_folder, "model.rds"))
  resamples <- readRDS(file.path(root_folder, "resamples.rds"))
  out <- NULL
  # Spark will more likely send more than one row (combination) in `x`. It
  # will depend on how the grid data frame was partitioned inside Spark.
  for (i in seq_len(nrow(x))) {
    curr_x <- x[i, ]
    resample <- get_rsplit(resamples, curr_x$index)
    params <- as.list(curr_x[, 1:(length(curr_x) - 2)])
    re_training <- as.data.frame(resample, data = "analysis")
    fitted_workflow <- workflow() |>
      add_recipe(finalize_recipe(pre_processing, params)) |>
      add_model(finalize_model(model, params)) |>
      fit(re_training)
    re_testing <- as.data.frame(resample, data = "assessment")
    wf_predict <- predict(fitted_workflow, re_testing)
    colnames(wf_predict) <- ".predictions"
    fin_bind <- cbind(re_testing, wf_predict)
    outcome_var <- tune::outcome_names(fitted_workflow)
    fin_metrics <- metrics(fin_bind, truth = outcome_var, estimate = ".predictions")
    curr <- cbind(as.data.frame(params), fin_metrics)
    curr$id <- curr_x$id
    colnames(curr) <- c(names(params), "metric", "estimator", "estimate", "id")
    out <- rbind(out, curr)
  }
  out
}
