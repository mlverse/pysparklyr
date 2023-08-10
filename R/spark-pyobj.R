#' @export
print.spark_pyobj <- function(x, ...) {
  cli_div(theme = cli_colors())
  cli_text("< {.header PySpark Object} >")
  cli_bullets(
    c(
      " " = "{.class {class(x$pyspark_obj)[[1]]}}",
      " " = "{.info {x$pyspark_obj}}"
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
  x$connection
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


to_pandas_cleaned <- function(x) {
  fields <- x$dtypes
  orig_types <- map_chr(fields, ~ .x[[2]])

  dec_types <- map_lgl(orig_types, ~ grepl("decimal\\(", .x))

  if (sum(dec_types) > 0) {
    sf <- import("pyspark.sql.functions")
    for (field in fields[dec_types]) {
      fn <- field[[1]]
      x <- x$withColumn(fn, sf$col(fn)$cast("double"))
    }
  }

  collected <- x$toPandas()
  col_types <- map_chr(
    collected, ~ {
      classes <- class(.x)
      classes[[1]]
    }
  )

  list_types <- col_types == "list"
  list_vars <- col_types[list_types]
  orig_vars <- orig_types[list_types]

  for (i in seq_along(list_vars)) {
    if (orig_vars[[i]] != "array") {
      cur_var <- names(list_vars[i])
      cur <- collected[[cur_var]]
      cur_null <- map_lgl(cur, is.null)
      cur <- as.character(cur)
      cur[cur_null] <- NA
      collected[[cur_var]] <- cur
    }
  }
  out <- tibble(collected)
  attr(out, "pandas.index") <- NULL
  out
}
