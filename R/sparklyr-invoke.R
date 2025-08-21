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
invoke.ml_connect_model <- function(jobj, method, ...) {
  invoke_conn(
    jobj = jobj,
    context = jobj,
    method = method,
    ... = ...
  )
}


#' @export
invoke.ml_connect_transformer <- function(jobj, method, ...) {
  invoke_conn(
    jobj = jobj,
    context = jobj,
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

#' @export
invoke.spark_pyobj <- function(jobj, method, ...) {
  invoke_conn(
    jobj = jobj,
    context = jobj,
    method = method,
    ...
  )
}

invoke_conn <- function(jobj, context, method, ...) {
  py_jobj <- python_obj_get(jobj)
  py_method <- python_obj_get(method)
  py_context <- python_obj_get(context)

  x <- py_get_attr(py_context, py_method)
  out <- NULL
  if (inherits(x, "python.builtin.method")) {
    run_x <- py_call(x, ...)

    if (inherits(run_x, "numpy.number") |
      inherits(run_x, "python.builtin.str") |
      inherits(run_x, "python.builtin.bool") |
      inherits(run_x, "python.builtin.int")
    ) {
      out <- py_to_r(run_x)
    }

    if (is.null(out)) {
      conn <- spark_connection(jobj)
      if(is.null(conn)) {
        stop("invoke cannot have a NULL connection")
      }
      out <- as_spark_pyobj(run_x, conn)
    }
  }

  if (is.null(out)) out <- py_to_r(x)

  out
}

#' @export
invoke_static.pyspark_connection <- function(sc, class, method, ...) {
  list()
}
