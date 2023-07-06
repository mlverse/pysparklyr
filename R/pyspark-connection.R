#' @export
spark_integ_test_skip.pyspark_connection <- function(sc, test_name) {
  out <- TRUE
  if(grepl("dplyr", test_name)) out <- FALSE
  if(grepl("dplyr-do", test_name)) out <- TRUE
  if(grepl("dplyr-hof", test_name)) out <- TRUE
  if(grepl("dplyr-cumprod", test_name)) out <- TRUE

  if(grepl("sample-n-weights", test_name)) out <- TRUE
  if(grepl("sample-n-replace", test_name)) out <- TRUE

  if(grepl("sample-with-seed", test_name)) out <- TRUE

  if(grepl("sample-frac-weights", test_name)) out <- TRUE
  if(grepl("sample-frac-replace", test_name)) out <- TRUE
  if(grepl("sample-frac-exact", test_name)) out <- TRUE

  if(grepl("dbi", test_name)) out <- FALSE
  if(grepl("tidyr", test_name)) out <- FALSE
  if(grepl("sdf-broadcast", test_name)) out <- TRUE
  if(grepl("ml-", test_name)) out <- TRUE

  out
}

#' @export
spark_version.pyspark_connection <- function(sc) {
  sc$state$spark_context$version
}

#' @export
connection_is_open.pyspark_connection <- function(sc) {
  # TODO: replace with actual connection state code
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
invoke_new.connect_spark <- function(jobj, class, ...) {
  classes <- unlist(strsplit(class, "[.]"))
  classes <- classes[classes != "org"]
  classes <- classes[classes != "apache"]
  classes <- classes[classes != "spark"]

  fn <- classes[length(classes)]
  lib <- classes[1:(length(classes) - 1)]

  ml_lib <- paste0(c("pyspark", lib), collapse = ".")

  imp <- import(ml_lib)
  ml_fun <- py_get_attr(imp, fn)
  as_spark_pyobj(obj = ml_fun, conn = jobj, class = class)
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
  if (inherits(x, "python.builtin.method")) {
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
