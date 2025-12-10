spark_session_root_folder <- function(sc) {
  connection_id <- sc[["connection_id"]]
  artifacts <- pysparklyr_env[["artifacts"]][[connection_id]]
  if(is.null(artifacts)) {
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
  if(is.null(file_name)){
    file_name <- rlang::hash(x)
  }
  files <- artifacts[["files"]]
  if(!file_name %in% artifacts[["files"]]) {
    temp_file <-  path_temp(file_name, ext = "rds")
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
    resamples = NULL
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


  grid_script <- pkg_path("udf/udf-tune-grid.R")
  grid_code <- readLines(grid_script)
  grid_code <- sub("preprocessing.rds", hash_preprocessor, grid_code)
  grid_code <- sub("model.rds", hash_model, grid_code)
  grid_code <- sub("resamples.rds", hash_resamples, grid_code)
  grid_code <- sub("root-folder-path", root_folder, grid_code)
  grid_code
  #grid_function <- as_function(function(x) eval(parse(text = grid_code)))
}



