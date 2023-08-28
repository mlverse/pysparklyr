#' @export
spark_integ_test_skip.connect_databricks <- function(sc, test_name) {
  spark_integ_generic(test_name)
}

#' @export
spark_integ_test_skip.connect_spark <- function(sc, test_name) {
  spark_integ_generic(test_name) %>%
    supports("format-csv", test_name) %>%
    supports("format-parquet", test_name) %>%
    supports("format-orc", test_name) %>%
    supports("format-json", test_name) %>%
    supports("format-text", test_name)
}


spark_integ_generic <- function(test_name) {
  out <- TRUE

  out %>%
    supports("dplyr", test_name) %>%
    supports("dplyr-do", test_name, TRUE) %>%
    supports("dplyr-hof", test_name, TRUE) %>%
    supports("dplyr-cumprod", test_name, TRUE) %>%
    supports("DBI", test_name) %>%
    supports("pivot-longer", test_name) %>%
    supports("pivot-longer-names-repair", test_name, TRUE) %>%
    supports("pivot-longer-values-transform", test_name, TRUE) %>%
    supports("ml-", test_name, TRUE) %>%
    supports("sdf-distinct", test_name)
}

supports <- function(x, test, test_name, default_out = FALSE) {
  if (grepl(test, test_name)) {
    x <- default_out
  }
  x
}
