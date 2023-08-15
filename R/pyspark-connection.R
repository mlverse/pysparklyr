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
  sc
}

#' @export
invoke.pyspark_connection <- function(jobj, method, ...) {
  invoke_conn(
    jobj = jobj,
    context = python_conn(jobj),
    method = method,
    ... = ...
  )
}

#' @export
invoke_new.connect_spark <- function(sc, class, ...) {
  classes <- unlist(strsplit(class, "[.]"))
  classes <- classes[classes != "org"]
  classes <- classes[classes != "apache"]
  classes <- classes[classes != "spark"]

  fn <- classes[length(classes)]
  lib <- classes[1:(length(classes) - 1)]

  ml_lib <- paste0(c("pyspark", lib), collapse = ".")

  imp <- import(ml_lib)
  ml_fun <- py_get_attr(imp, fn)
  as_spark_pyobj(obj = ml_fun, conn = sc, class = class)
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
  out <- NULL
  if (inherits(x, "python.builtin.method")) {
    run_x <- py_call(x, ...)

    if (inherits(run_x, "numpy.number")) {
      out <- py_to_r(run_x)
    }

    if (is.null(out)) {
      out <- as_spark_pyobj(run_x, jobj)
    }
  }

  if (is.null(out)) out <- py_to_r(x)

  out
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
