#' @export
spark_version.pyspark_connection<- function(sc) {
  sc$state$spark_context$version
}

#' @export
connection_is_open.pyspark_connection <- function(sc) {
  #TODO: replace with actual connection state code
  TRUE
}

#' @export
spark_connection.pyspark_connection <- function(sc) {
  sc
}

#' @export
hive_context.pyspark_connection <- function(sc) {
  sc
}

#' @export
spark_session.pyspark_connection <- function(sc) {
  sc
}

#' @export
invoke.pyspark_connection <- function(jobj, method, ...) {
  invoke_conn(
    jobj = jobj,
    context = jobj$state$spark_context,
    method = method,
    ... = ...
  )
}

#' @export
invoke.python.builtin.object <- function(jobj, method, ...) {
  invoke_conn(
    jobj = jobj,
    context = jobj,
    method = method,
    ... = ...
  )
}

invoke_conn <- function(jobj, context, method, ...) {
  x <- py_get_attr(context, method)
  if(inherits(x, "python.builtin.method")) {
    run_x <- py_call(x, ...)
    out <- as_spark_pyobj(run_x, jobj)
  } else {
    out <- py_to_r(x)
  }
  out
}

#' @export
spark_dataframe.pyspark_connection <- function(x, ...) {
  x
}

as_spark_pyobj <- function(obj, conn) {
  structure(
    list(
      pyspark_obj = obj,
      connection = conn
    ),
    class = "spark_pyobj"
  )
}
setOldClass("spark_pyobj")
