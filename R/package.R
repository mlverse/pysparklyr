#' @importFrom sparklyr spark_session invoke invoke_new spark_dataframe spark_web
#' @importFrom sparklyr spark_connection connection_is_open hive_context
#' @importFrom sparklyr sdf_copy_to spark_connect_method
#' @importFrom dplyr tbl collect
#' @importFrom methods new is
#' @import reticulate
#' @import dbplyr
#' @import glue
#' @import cli
#' @import DBI
NULL

pysparklyr_env <- new.env()
