#' @export
spark_integ_test_skip.pyspark_connection <- function(sc, test_name) {
  out <- TRUE
  if (grepl("dplyr", test_name)) out <- FALSE
  if (grepl("dplyr-do", test_name)) out <- TRUE
  if (grepl("dplyr-hof", test_name)) out <- TRUE
  if (grepl("dplyr-cumprod", test_name)) out <- TRUE

  if (grepl("sample-n-weights", test_name)) out <- TRUE
  if (grepl("sample-n-replace", test_name)) out <- TRUE

  if (grepl("sample-with-seed", test_name)) out <- TRUE

  if (grepl("sample-frac-weights", test_name)) out <- TRUE
  if (grepl("sample-frac-replace", test_name)) out <- TRUE
  if (grepl("sample-frac-exact", test_name)) out <- TRUE

  if (grepl("dbi", test_name)) out <- FALSE
  if (grepl("sdf-broadcast", test_name)) out <- TRUE
  if (grepl("ml-", test_name)) out <- TRUE

  if (grepl("supports-nas", test_name)) out <- TRUE

  out
}
