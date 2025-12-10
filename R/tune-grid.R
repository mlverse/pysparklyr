spark_session_root_folder <- function(sc) {
  connection_id <- sc[["connection_id"]]
  if(is.null(pysparklyr_env$root_folders[[connection_id]])) {
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
    pysparklyr_env$root_folders[[connection_id]] <- root_folder
  }
  pysparklyr_env$root_folders[[connection_id]]
}
