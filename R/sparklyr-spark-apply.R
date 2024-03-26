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
  py_check_installed(
    libraries = "rpy2",
    msg = "Requires an additional Python library"
  )
  cli_div(theme = cli_colors())
  if (!is.null(packages)) {
    cli_abort("`packages` is not yet supported for this backend")
  }
  if (!is.null(context)) {
    cli_abort("`context` is not supported for this backend")
  }
  if (auto_deps) {
    cli_abort("`auto_deps` is not supported for this backend")
  }
  if (partition_index_param != "") {
    cli_abort("`partition_index_param` is not supported for this backend")
  }
  if (!is.null(arrow_max_records_per_batch)) {
    sc <- python_sdf(x)$sparkSession
    conf_name <- "spark.sql.execution.arrow.maxRecordsPerBatch"
    conf_curr <- sc$conf$get(conf_name)
    conf_req <- as.character(arrow_max_records_per_batch)
    if (conf_curr != conf_req) {
      cli_div(theme = cli_colors())
      cli_inform(
        "{.header Changing {.emph {conf_name}} to: {prettyNum(conf_req, big.mark = ',')}}"
      )
      cli_end()
      sc$conf$set(conf_name, conf_req)
    }
  }
  cli_end()
  sa_in_pandas(
    x = x,
    .f = f,
    .schema = columns,
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
    .schema = NULL,
    .schema_arg = "columns",
    .group_by = NULL,
    .as_sdf = TRUE,
    .name = NULL,
    .barrier = NULL) {
  schema_msg <- FALSE
  if (is.null(.schema)) {
    r_fn <- .f %>%
      sa_function_to_string(
        .r_only = TRUE,
        .group_by = .group_by,
        .colnames = NULL,
        ... = ...
      ) %>%
      rlang::parse_expr() %>%
      eval()
    r_df <- x %>%
      head(10) %>%
      collect()
    r_exec <- r_fn(r_df)
    col_names <- colnames(r_exec)
    col_names <- gsub("\\.", "_", col_names)
    colnames(r_exec) <- col_names
    .schema <- r_exec %>%
      imap(~ {
        x_class <- class(.x)
        if ("POSIXt" %in% x_class) x_class <- "timestamp"
        if (x_class == "character") x_class <- "string"
        if (x_class == "numeric") x_class <- "double"
        if (x_class == "integer") x_class <- "long"
        paste0(.y, " ", x_class)
      }) %>%
      paste0(collapse = ", ")
    schema_msg <- TRUE
  } else {
    fields <- unlist(strsplit(.schema, ","))
    col_names <- map_chr(fields, ~ unlist(strsplit(trimws(.x), " "))[[1]])
    col_names <- gsub("\\.", "_", col_names)
  }
  .f %>%
    sa_function_to_string(
      .group_by = .group_by,
      .colnames = col_names,
      ... = ...
    ) %>%
    py_run_string()
  main <- reticulate::import_main()
  df <- python_sdf(x)
  if (is.null(df)) {
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
  if (.as_sdf) {
    ret <- tbl_pyspark_temp(
      x = p_df,
      conn = spark_connection(x),
      tmp_name = .name
    )
  } else {
    ret <- to_pandas_cleaned(p_df)
  }
  if (schema_msg) {
    schema_arg <- .schema_arg
    schema <- .schema
    cli_div(theme = cli_colors())
    cli_inform(c(
      "{.header To increase performance, use the following schema:}",
      "{.emph {schema_arg} = \"{schema}\" }"
    ))
    cli_end()
  }
  ret
}

sa_function_to_string <- function(
    .f,
    .group_by = NULL,
    .r_only = FALSE,
    .colnames = NULL,
    ...) {
  path_scripts <- system.file("udf", package = "pysparklyr")
  if (dir_exists("inst/udf")) {
    path_scripts <- path_expand("inst/udf")
  }
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
  if (is.null(.colnames)) {
    .colnames <- "NULL"
  } else {
    .colnames <- paste0("'", .colnames, "'", collapse = ", ")
  }
  fn_r <- gsub(
    "col_names <- c\\('am', 'x'\\)",
    paste0("col_names <- c(", .colnames, ")"),
    fn_r
  )
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
  if (.r_only) {
    ret <- fn_r_new
  } else {
    ret <- gsub(fn_rep, fn_r_new, fn_python)
  }
  ret
}
