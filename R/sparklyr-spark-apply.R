#' @export
spark_apply.tbl_pyspark <- function(
    x,
    f,
    columns = NULL,
    memory = TRUE,
    group_by = NULL,
    packages = NULL,
    context = NULL,
    name = NULL,
    barrier = NULL,
    fetch_result_as_sdf = TRUE,
    partition_index_param = "",
    arrow_max_records_per_batch = NULL,
    auto_deps = FALSE,
    ...) {
  sa_in_pandas(
    x = x,
    .f = f,
    .schema = columns,
    .group_by = group_by
    )
}

sa_in_pandas <- function(x, .f, ..., .schema = "x double", .group_by = NULL) {
  fn <- sa_function_to_string(.f = .f, .group_by = .group_by, ... = ...)
  py_run_string(fn)
  main <- reticulate::import_main()
  df <- x[[1]]$session
  if (!is.null(.group_by)) {
    # TODO: Add support for multiple grouping columns
    renamed_gp <- paste0("_", .group_by)
    w_gp <- df$withColumn(colName = renamed_gp, col = df[.group_by])
    tbl_gp <- w_gp$groupby(renamed_gp)
    ret <- tbl_gp$applyInPandas(main$r_apply, schema = .schema)$toPandas()
  } else {
    ret <- df$mapInPandas(main$r_apply, schema = .schema)$toPandas()
  }
  ret
}

sa_function_to_string <- function(.f, .group_by = NULL, ...) {
  path_scripts <- system.file("udf", package = "pysparklyr")
  if (!is.null(.group_by)) {
    udf_r <- "udf-apply.R"
    udf_py <- "udf-apply.py"
  } else {
    udf_r <- "udf-map.R"
    udf_py <- "udf-map.py"
  }
  fn_r <- paste0(
    readLines(path(path_scripts, udf_r)),
    collapse = ""
  )
  fn_python <- paste0(
    readLines(path(path_scripts, udf_py)),
    collapse = "\n"
  )
  if (!is.null(.group_by)) {
    fn_r <- gsub(
      "gp_field <- 'am'",
      paste0("gp_field <- '", .group_by, "'"),
      fn_r
    )
  }
  fn <- purrr::as_mapper(.f = .f, ... = ...)
  fn_str <- paste0(deparse(fn), collapse = "")
  if (inherits(fn, "rlang_lambda_function")) {
    fn_str <- paste0(
      "function(...) {x <- (",
      fn_str,
      "); x(...)}"
    )
  }
  fn_str <- gsub("\"", "'", fn_str)
  fn_rep <- "function\\(\\.\\.\\.\\) 1"
  fn_r_new <- gsub(fn_rep, fn_str, fn_r)
  gsub(fn_rep, fn_r_new, fn_python)
}
