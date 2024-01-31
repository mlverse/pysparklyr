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
  cli_div(theme = cli_colors())
  if(!is.null(packages)) {
    cli_abort("`packages` is not yet supported for this backend")
  }
  if(!is.null(context)) {
    cli_abort("`context` is not supported for this backend")
  }
  if(auto_deps) {
    cli_abort("`auto_deps` is not supported for this backend")
  }
  if(partition_index_param != "") {
    cli_abort("`partition_index_param` is not supported for this backend")
  }
  cli_end()
  sa_in_pandas(
    x = x,
    .f = f,
    .schema = columns %||% "x double",
    .group_by = group_by,
    .as_sdf = fetch_result_as_sdf,
    .name = name,
    .barrier = barrier,
    ... = ...
    )
}

sa_in_pandas <- function(
    x,
    .f,
    ...,
    .schema = "x double",
    .group_by = NULL,
    .as_sdf = TRUE,
    .name = NULL,
    .barrier = NULL
    ) {
  .f %>%
    sa_function_to_string(.group_by = .group_by, ... = ...) %>%
    py_run_string()
  main <- reticulate::import_main()
  df <- python_sdf(x)
  if(is.null(df)) {
    df <- x %>%
      compute() %>%
      python_sdf()
  }
  if (!is.null(.group_by)) {
    # TODO: Add support for multiple grouping columns
    renamed_gp <- paste0("_", .group_by)
    w_gp <- df$withColumn(colName = renamed_gp, col = df[.group_by])
    tbl_gp <- w_gp$groupby(renamed_gp)
    p_df <- tbl_gp$applyInPandas(
      main$r_apply,
      schema = .schema
      )
  } else {
    p_df <- df$mapInPandas(
      main$r_apply,
      schema = .schema,
      barrier = .barrier %||% FALSE
      )
  }
  if(.as_sdf) {
    ret <- tbl_pyspark_temp(
      x = p_df,
      conn = spark_connection(x),
      tmp_name = .name
      )
  } else {
    ret <- to_pandas_cleaned(p_df)
  }
  ret
}

sa_function_to_string <- function(.f, .group_by = NULL, ...) {
  path_scripts <- system.file("udf", package = "pysparklyr")
  udf_fn <- ifelse(is.null(.group_by), "map", "apply")
  fn_r <- paste0(
    readLines(path(path_scripts, glue("udf-{udf_fn}.R"))),
    collapse = ""
  )
  fn_python <- paste0(
    readLines(path(path_scripts, glue("udf-{udf_fn}.py"))),
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
