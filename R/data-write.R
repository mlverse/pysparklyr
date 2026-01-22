#' @export
spark_write_delta.tbl_pyspark <- function(
  x,
  path,
  mode = NULL,
  options = list(),
  partition_by = NULL,
  ...
) {
  pyspark_write_generic(
    x = x,
    path = path,
    format = "delta",
    mode = mode,
    partition_by = partition_by,
    options = options,
    args = list()
  )
}

#' @export
spark_write_table.tbl_pyspark <- function(
  x,
  name,
  mode = NULL,
  options = list(),
  partition_by = NULL,
  ...
) {
  args <- list(...)
  save_action <- ifelse(identical(mode, "append"), "insertInto", "saveAsTable")
  pyspark_write_generic(
    x = x,
    path = name,
    format = args$format,
    mode = mode,
    partition_by = partition_by,
    options = options,
    args = list(),
    save_action = save_action,
    expand_path = FALSE
  )
}

#' @export
spark_write_csv.tbl_pyspark <- function(
  x,
  path,
  header = TRUE,
  delimiter = ",",
  quote = "\"",
  escape = "\\",
  charset = "UTF-8",
  null_value = NULL,
  options = list(),
  mode = NULL,
  partition_by = NULL,
  ...
) {
  pyspark_write_generic(
    x = x,
    path = path,
    format = "csv",
    partition_by = partition_by,
    mode = mode,
    options = options,
    args = list(
      header = header,
      delimiter = delimiter,
      quote = quote,
      charset = charset
    )
  )
}

#' @export
spark_write_parquet.tbl_pyspark <- function(
  x,
  path,
  mode = NULL,
  options = list(),
  partition_by = NULL,
  ...
) {
  pyspark_write_generic(
    x = x,
    path = path,
    format = "parquet",
    mode = mode,
    partition_by = partition_by,
    options = options,
    args = list()
  )
}

#' @export
spark_write_text.tbl_pyspark <- function(
  x,
  path,
  mode = NULL,
  options = list(),
  partition_by = NULL,
  ...
) {
  pyspark_write_generic(
    x = x,
    path = path,
    format = "text",
    mode = mode,
    partition_by = partition_by,
    options = options,
    args = list()
  )
}

#' @export
spark_write_orc.tbl_pyspark <- function(
  x,
  path,
  mode = NULL,
  options = list(),
  partition_by = NULL,
  ...
) {
  pyspark_write_generic(
    x = x,
    path = path,
    format = "orc",
    mode = mode,
    partition_by = partition_by,
    options = options,
    args = list()
  )
}

#' @export
spark_write_json.tbl_pyspark <- function(
  x,
  path,
  mode = NULL,
  options = list(),
  partition_by = NULL,
  ...
) {
  pyspark_write_generic(
    x = x,
    path = path,
    format = "json",
    mode = mode,
    partition_by = partition_by,
    options = options,
    args = list()
  )
}

pyspark_write_generic <- function(
  x,
  path,
  format = NULL,
  mode,
  partition_by,
  options,
  args,
  save_action = "save",
  expand_path = TRUE
) {
  query <- tbl_pyspark_sdf(x)

  if (is.null(partition_by)) {
    query_prep <- query$repartition(1L)$write
  } else {
    query_prep <- query$write$partitionBy(partition_by)
  }

  opts <- c(args, options)

  path <- ifelse(expand_path, path_expand(path), path)

  if (!is.null(format)) {
    x <- py_invoke(query_prep, "format", format)
  } else {
    x <- query_prep
  }

  if (!is.null(mode)) {
    x <- py_invoke(x, "mode", mode)
  }

  invisible(
    x |>
      py_invoke_options(options = opts) |>
      py_invoke(save_action, path)
  )
}

py_invoke <- function(x, fun, ...) {
  x |>
    py_get_attr(fun) |>
    py_call(...)
}

py_invoke_option <- function(x, option, value) {
  if (!is.null(value)) {
    out <- py_invoke(x, "option", option, value)
  } else {
    out <- x
  }
  out
}

py_invoke_options <- function(x, options) {
  for (i in seq_along(options)) {
    curr_option <- options[i]
    x <- py_invoke_option(x, names(curr_option), curr_option[[1]])
  }
  x
}
