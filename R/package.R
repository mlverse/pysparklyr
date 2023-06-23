#' @importFrom sparklyr spark_session invoke spark_dataframe
#' @importFrom sparklyr spark_connection connection_is_open hive_context
#' @import reticulate
#' @import cli
#' @import glue
NULL

pysparklyr_env <- new.env()
