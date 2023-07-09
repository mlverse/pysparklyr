#' @importFrom sparklyr spark_session invoke invoke_new spark_dataframe spark_web
#' @importFrom sparklyr sdf_copy_to spark_connect_method spark_log random_string
#' @importFrom sparklyr spark_table_name spark_integ_test_skip spark_ide_preview
#' @importFrom sparklyr spark_connection connection_is_open hive_context
#' @importFrom sparklyr spark_ide_objects spark_ide_columns
#' @importFrom tidyselect tidyselect_data_has_predicates
#' @importFrom dplyr tbl collect tibble same_src compute
#' @importFrom purrr map_lgl map_chr map
#' @importFrom rlang enquo `!!` quo_is_null
#' @importFrom methods new is
#' @import reticulate
#' @import dbplyr
#' @import glue
#' @import cli
#' @import DBI
#' @import fs
NULL

pysparklyr_env <- new.env()
