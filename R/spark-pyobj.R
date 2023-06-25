#' @export
spark_version.spark_pyobj <- function(sc) {
  sc$connection$state$spark_context$version
}

#' @export
spark_context.spark_pyobj <- function(sc) {
  sc$connection
}

#' @export
spark_connection.spark_pyobj <- function(sc) {
  sc$connection
}

#' @export
spark_dataframe.spark_pyobj <- function(x, ...) {
  x
}

#' @export
invoke.spark_pyobj <- function(jobj, method, ...) {
  invoke_conn(
    jobj = jobj$connection,
    context = jobj$pyspark_obj,
    method = method,
    ... = ...
  )
}

#' @export
collect.spark_pyobj <- function(x, ...) {
  x$pyspark_obj$toPandas()
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
