#' @export
spark_integ_test_skip.pyspark_connection <- function(sc, test_name) {

  supports <- function(x, test, default_out = FALSE) {
    if (grepl(test, test_name)) {
      x <- default_out
    }
    x
  }

  out <- TRUE

  out %>%
    supports("dplyr") %>%
    supports("dplyr-do", TRUE) %>%
    supports("dplyr-hof", TRUE) %>%
    supports("dplyr-cumprod", TRUE) %>%
    supports("DBI") %>%
    supports("format-csv") %>%
    supports("format-parquet") %>%
    supports("format-orc") %>%
    supports("format-json") %>%
    supports("format-text") %>%
    supports("pivot-longer") %>%
    supports("ml-", TRUE)
}
