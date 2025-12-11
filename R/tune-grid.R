spark_session_root_folder <- function(sc) {
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

spark_tune_grid_impl <- function(
  sc,
  preprocessor = NULL,
  model = NULL,
  resamples = NULL,
  grid = NULL
) {
  # Get the location in the Spark driver where the files will be
  # temporariliy uploaded to
  root_folder <- spark_session_root_folder(sc)

  # Hashing R objects
  hash_preprocessor <- rlang::hash(preprocessor)
  hash_model <- rlang::hash(model)
  hash_resamples <- rlang::hash(resamples)

  # Copying R objects to R session
  spark_session_add_file(preprocessor, sc, hash_preprocessor)
  spark_session_add_file(model, sc, hash_model)
  spark_session_add_file(resamples, sc, hash_resamples)

  grid_code <- paste0(deparse(loop_call), collapse = "\n")
  grid_code <- sub("preprocessing.rds", path(hash_preprocessor, ext = "rds"), grid_code)
  grid_code <- sub("model.rds", path(hash_model, ext = "rds"), grid_code)
  grid_code <- sub("resamples.rds", path(hash_resamples, ext = "rds"), grid_code)
  grid_code <- sub("path/to/root", root_folder, grid_code)

  full_grid <- data.frame()
  for (i in seq_along(resamples$splits)) {
    temp_grid <- grid
    temp_grid$index <- i
    temp_grid$id <- resamples$id[[i]]
    full_grid <- rbind(full_grid, temp_grid)
  }

  temp_grid <- copy_to(sc, full_grid, name = "temp_grid", overwrite = TRUE)

  cols <- paste0(
    "num_comp integer, tree_depth integer, metric string,",
    " estimator string, estimate double, id string"
  )

  temp_grid |>
    spark_apply(
      f = grid_code,
      columns = cols
    )
}

loop_call <- function(x) {
  library(tidymodels)
  root_folder <- Sys.getenv('TEMP_SPARK_GRID')
  if(root_folder == "") {
    root_folder <- "path/to/root"
  }
  pre_processing <- readRDS(file.path(root_folder, "preprocessing.rds"))
  model <- readRDS(file.path(root_folder, "model.rds"))
  resamples <- readRDS(file.path(root_folder, "resamples.rds"))
  out <- NULL
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
    var_info <- pre_processing$var_info
    outcome_var <- var_info$variable[var_info$role == "outcome"]
    wf_predict <- predict(fitted_workflow, re_testing)
    colnames(wf_predict) <- ".predictions"
    fin_bind <- cbind(re_testing, wf_predict)
    var_info <- pre_processing$var_info
    outcome_var <- var_info$variable[var_info$role == "outcome"]
    fin_metrics <- metrics(fin_bind, truth = outcome_var, estimate = ".predictions")
    curr <- cbind(as.data.frame(params), fin_metrics)
    curr$id <- curr_x$id
    colnames(curr) <- c(names(params), "metric", "estimator", "estimate", "id")
    out <- rbind(out, curr)
  }
  out
}
