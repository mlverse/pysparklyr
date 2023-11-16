#' @export
spark_version.pyspark_connection <- function(sc) {
  python_conn(sc)$version
}

#' @export
connection_is_open.pyspark_connection <- function(sc) {
  # TODO: replace with actual connection state code
  TRUE
}

#' @export
spark_connection.pyspark_connection <- function(x, ...) {
  x
}

#' @export
hive_context.pyspark_connection <- function(sc) {
  sc
}

#' @export
spark_session.pyspark_connection <- function(sc) {
  sc$session
}

#' @export
spark_dataframe.pyspark_connection <- function(x, ...) {
  x
}

#' @export
spark_web.pyspark_connection <- function(sc, ...) {
  # TODO: Implement later when SparkContext is implemented
  ""
}

#' @export
spark_log.pyspark_connection <- function(sc, n = 100, filter = NULL, ...) {
  # TODO: Implement later when SparkContext is implemented
  ""
}
