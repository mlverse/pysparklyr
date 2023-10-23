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


# ' @export
# spark_session.tbl_pyspark <- function(x) x$src$state$spark_context


#' @export
`[.tbl_pyspark` <- function(x, i) {
  # this is defined to match the interface to sparklyr::`[.tbl_spark`. But it really
  # should be more flexible, taking row specs, multiple args, etc. matching
  # semantics of R dataframes and take advantage of
  # reticulate::`[.python.builtin.object` for constructing slices, etc.
  if (is.null(i)) {
    # special case, since pyspark has no "emptyDataFrame" method to invoke
    sc <- spark_connection(x)

    pyspark.sql.types <- reticulate::import("pyspark.sql.types")
    ss <- x$src$state$spark_context # SparkSession obj
    edf <- ss$createDataFrame(list(), pyspark.sql.types$StructType(list()))

    tmp_name <- tbl_temp_name()
    edf$createOrReplaceTempView(tmp_name)
    return(tbl(sc, tmp_name))
  }
  NextMethod()
}

#' @export
invoke_static.pyspark_connection <- function(sc, class, method, ...) {
  list()
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
invoke.tbl_pyspark <- function(jobj, method, ...) {
  invoke_conn(
    jobj = jobj,
    context = jobj,
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
  jobj <- python_obj_get(jobj)
  method <- python_obj_get(method)
  context <- python_obj_get(context)

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
