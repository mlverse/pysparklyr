#' @export
spark_version.python.builtin.object <- function(sc) {
  sc$sparkSession$version
}

#' @export
spark_context.python.builtin.object <- function(sc) {
  sc$sparkSession
}

#' @export
spark_connection.python.builtin.object <- function(sc) {
  sc$sparkSession
}

#' @export
invoke.python.builtin.object <- function(jobj, method, ...) {
  py_call(py_get_attr(jobj, method), ...)
}

#' @export
spark_dataframe.python.builtin.object <- function(x, ...) {
  x
}

#' @importFrom dplyr collect
#' @export
collect.python.builtin.object <- function(x, ...) {
  x$toPandas()
}
