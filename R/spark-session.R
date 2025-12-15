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
