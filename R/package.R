#' @importFrom sparklyr spark_session invoke invoke_new spark_dataframe spark_web
#' @importFrom sparklyr spark_connection connection_is_open hive_context
#' @importFrom methods new is
#' @import reticulate
#' @import cli
#' @import glue
#' @import DBI
#' @import dbplyr
NULL

pysparklyr_env <- new.env()
