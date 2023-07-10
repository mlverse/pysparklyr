#' @importFrom sparklyr spark_write_csv spark_write_parquet
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

  pyspark_write_generic(
    x = x,
    path = path,
    format = "csv",
    partition_by = partition_by,
    mode = mode,
    options = options,
    args = list(
      header = header,
      delimiter = delimiter,
      quote = quote,
      charset = charset
    )
  )
}

#' @export
spark_write_parquet.tbl_pyspark <- function(
    x,
    path,
    mode = NULL,
    options = list(),
    partition_by = NULL,
    ...) {
  pyspark_write_generic(
    x = x,
    path = path,
    format = "parquet",
    mode = mode,
    partition_by = partition_by,
    options = options,
    args = list()
  )
}

pyspark_write_generic <- function(x, path, format, mode, partition_by, options, args){
  sc <- spark_connection(x)
  con <- python_conn(sc)

  query <- con$sql(remote_query(x))

  if (is.null(partition_by)) {
    query_prep <- query$repartition(1L)$write
  } else {
    query_prep <- query$write$partitionBy(partition_by)
  }

  opts <- c(args, options)

  query_prep %>%
    py_invoke("format", format) %>%
    py_invoke_options(options = opts) %>%
    py_invoke("save", path_expand(path))
}

py_invoke <- function(x, fun, ...) {
  x %>%
    py_get_attr(fun) %>%
    py_call(...)
}

py_invoke_option <- function(x, option, value) {
  if (!is.null(value)) {
    out <- py_invoke(x, "option", option, value)
  } else {
    out <- x
  }
  out
}

py_invoke_options <- function(x, options) {
  for(i in seq_along(options)) {
    curr_option <- options[i]
    x <- py_invoke_option(x, names(curr_option), curr_option[[1]])
  }
  x
}
