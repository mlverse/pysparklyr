#' @export
print.spark_pyobj <- function(x, ...) {
  pyspark_obj <- x$pyspark_obj
  pyspark_class <- class(pyspark_obj)[[1]]
  pyspark_print <- py_str(pyspark_obj)
  cli_div(theme = cli_colors())
  cli_text("{.header - {.emph PySpark object}}")
  cli_bullets(
    c(
      " " = "{.class {pyspark_class}}",
      " " = "{.info {pyspark_print}}"
    )
  )
  cli_end()
}

#' @export
sdf_read_column.spark_pyjobj <- function(x, column) {
  col_df <- x %>%
    spark_dataframe() %>%
    invoke("select", column) %>%
    collect()

  col_df[[column]]
}

#' @export
spark_version.spark_pyobj <- function(sc) {
  python_conn(sc)$version
}

#' @export
spark_connection.spark_pyobj <- function(x, ...) {
  x[["connection"]]
}

#' @export
spark_dataframe.spark_pyobj <- function(x, ...) {
  x
}

#' @export
collect.spark_pyobj <- function(x, ...) {
  to_pandas_cleaned(x$pyspark_obj)
}

as_spark_pyobj <- function(obj, conn, class = NULL) {
  structure(
    list(
      pyspark_obj = obj,
      connection = conn,
      class = class
    ),
    class = c("spark_pyobj", "spark_jobj")
  )
}
setOldClass(c("spark_pyobj", "spark_jobj"))

get_spark_pyobj <- function(obj) {
  obj[[".jobj"]]
}
