#' @export
spark_connect_method.spark_method_snowpark_connect <- function(
  x,
  method,
  master,
  spark_home,
  config = NULL,
  app_name,
  version = NULL,
  hadoop_version,
  extensions,
  scala_version,
  ...
) {
  master_explicit <- !missing(master) && !is.null(master)
  if (!master_explicit) {
    master <- Sys.getenv("SNOWFLAKE_ACCOUNT", unset = NA)
    if (is.na(master)) master <- NULL
  }
  args <- list(...)
  envname <- use_envname(
    backend = "snowflake",
    main_library = "snowflake-snowpark-python",
    version = version %||% "latest",
    envname = args$envname,
    messages = TRUE,
    match_first = TRUE,
    python_version = args$python_version
  )
  if (is.null(envname)) {
    return(invisible())
  }
  pyspark <- import_check("snowflake.snowpark", envname)
  connection_parameters <- args$connection_parameters %||% list()

  using_named_connection <-
    !is.null(connection_parameters$connection_name) ||
    nzchar(Sys.getenv("SNOWFLAKE_DEFAULT_CONNECTION_NAME"))

  effective_account <- if (!using_named_connection || master_explicit) {
    master %||% connection_parameters$account
  } else {
    connection_parameters$account
  }
  snowflake_url <- if (!is.null(effective_account)) {
    paste0("https://", effective_account, ".snowflakecomputing.com")
  }

  if (!is.null(snowflake_url) && has_viewer_token(snowflake_url)) {
    token_obj <- connect_viewer_token(snowflake_url)
    connection_parameters$account <- effective_account
    connection_parameters$authenticator <- "oauth"
    connection_parameters$token <- token_obj$access_token
  } else if (!is.null(master) && (!using_named_connection || master_explicit)) {
    connection_parameters$account <- master
  }

  if (!using_named_connection && !is.null(master)) {
    missing_path <- NULL
    if (is.null(connection_parameters$warehouse)) {
      missing_path <- "warehouse"
    }
    if (is.null(connection_parameters$database)) {
      missing_path <- c(missing_path, "database")
    }
    if (is.null(connection_parameters$schema)) {
      missing_path <- c(missing_path, "schema")
    }
    if (!is.null(missing_path)) {
      missing_path <- paste0("'", missing_path, "'")
      cli_alert_warning(
        "Argument{?s} {.pkg {missing_path}} will be needed to easily navigate Snowflake"
      )
      cli_bullets(
        c(" " = "Please use the `connection_parameters` argument to pass them.")
      )
    }
  }

  conn <- pyspark$Session$builder$configs(connection_parameters)
  con_class <- "connect_snowflake"
  master_label <- if (!is.null(effective_account)) {
    glue("Snowpark Connect - {effective_account}")
  } else {
    "Snowpark Connect"
  }
  initialize_connection(
    conn = conn,
    master_label = master_label,
    con_class = con_class,
    cluster_id = NULL,
    method = method,
    config = NULL,
    misc = list(
      sql_catalogs = "show databases",
      sql_tables_schema = "show tables in {schema}",
      sql_tables_catalog_schema = "show tables in {catalog}.{schema}",
      sql_schemas_catalog = "show schemas in database {catalog}",
      sql_schemas = "show schemas"
    ),
    quote = ""
  )
}

setOldClass(
  c("connect_snowflake", "pyspark_connection", "spark_connection")
)
