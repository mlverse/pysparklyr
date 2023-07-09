#' @importFrom sparklyr spark_write_csv
#' @export
spark_write_csv.tbl_pyspark <- function(
    x,
    path,
    header = TRUE,
    delimiter = ",",
    quote = "\"",
    escape = "\\",
    charset = "UTF-8",
    null_value = NULL,
    options = list(),
    mode = NULL,
    partition_by = NULL,
    ...) {

  sc <- spark_connection(x)
  con <- python_conn(sc)

  query <- con$sql(remote_query(x))

  if(is.null(partition_by)) {
    query_prep <- query$repartition(1L)$write
  } else {
    query_prep <- query$write$partitionBy(partition_by)
  }

  tmp_folder <- tempdir()

  query$repartition(1L)$write %>%
    py_invoke("format", "csv") %>%
    py_invoke("save", "/Users/edgar/r_projects/pysparklyr/test.csv")


}

py_invoke <- function(x, fun, ...){
  x %>%
    py_get_attr(fun) %>%
    py_call(... = ...)
}
