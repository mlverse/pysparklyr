#' @importFrom sparklyr spark_session invoke invoke_new spark_dataframe spark_web
#' @importFrom sparklyr sdf_copy_to spark_connect_method spark_log random_string
#' @importFrom sparklyr spark_table_name spark_integ_test_skip spark_ide_preview
#' @importFrom sparklyr spark_connection connection_is_open hive_context
#' @importFrom sparklyr spark_ide_objects spark_ide_columns sdf_read_column
#' @importFrom sparklyr spark_ide_connection_updated spark_version
#' @importFrom sparklyr spark_read_csv spark_read_parquet spark_read_text
#' @importFrom sparklyr spark_read_json spark_read_orc
#' @importFrom sparklyr spark_write_csv spark_write_parquet spark_write_text
#' @importFrom sparklyr spark_write_orc spark_write_json
#' @importFrom sparklyr spark_install_find
#' @importFrom tidyselect tidyselect_data_has_predicates
#' @importFrom dplyr tbl collect tibble same_src compute as_tibble group_vars
#' @importFrom dplyr sample_n sample_frac slice_sample select tbl_ptype group_by
#' @importFrom purrr map_lgl map_chr map pmap_chr
#' @importFrom rlang enquo `!!` `!!!` quo_is_null sym arg_match warn abort `%||%`
#' @importFrom rlang is_string is_character as_utf8_character parse_exprs
#' @importFrom methods new is setOldClass
#' @importFrom tidyselect matches
#' @importFrom utils head type.convert
#' @importFrom tidyr pivot_longer
#' @importFrom vctrs vec_as_names
#' @importFrom processx process
#' @import reticulate
#' @import dbplyr
#' @import glue
#' @import cli
#' @import DBI
#' @import fs
NULL

.onLoad <- function(...) {
  use_virtualenv("r-sparklyr", required = FALSE)
  use_condaenv("r-sparklyr", required = FALSE)
}

globalVariables("RStudio.Version")

pysparklyr_env <- new.env()
pysparklyr_env$temp_prefix <- "sparklyr_tmp_"
temp_prefix <- function() pysparklyr_env$temp_prefix
