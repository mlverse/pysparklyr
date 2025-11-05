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
  if (missing(master) || is.null(master)) {
    master <- Sys.getenv("SNOWFLAKE_ACCOUNT", unset = NA)
    if (is.na(master)) {
      cli_abort(paste(
        "Please provide a `master` argument. It needs to be your Snowflake's",
        "'Account Identifier', which can be found in the portal."
      ))
    }
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
  connection_parameters <- args$connection_parameters
  connection_parameters["account"] <- master
  if (is.null(connection_parameters[["password"]])) {
    # Checks to see if there is a Posit Workbench token available
    snowflake_home <- Sys.getenv("SNOWFLAKE_HOME", unset = NA)
    if (!is.na(snowflake_home)) {
      if (grepl("workbench", snowflake_home)) {
        token <- try(workbench_snowflake_token(master, snowflake_home), silent = TRUE)
        if (!inherits(token, "try-error")) {
          connection_parameters[["authenticator"]] <- "oauth"
          connection_parameters[["token"]] <- token
        }
      }
    }
  }
  conn <- pyspark$Session$builder$configs(connection_parameters)
  con_class <- "connect_snowflake"
  master_label <- glue("Snowpark Connect - {master}")
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

# Copy of code from `odbc` which gets the Snowflake token from Workbench
# https://github.com/r-dbi/odbc/blob/main/R/driver-snowflake.R
workbench_snowflake_token <- function(account, sf_home) {
  cfg <- readLines(file.path(sf_home, "connections.toml"))
  # We don't attempt a full parse of the TOML syntax, instead relying on the
  # fact that this file will always contain only one section.
  if (!any(grepl(account, cfg, fixed = TRUE))) {
    # The configuration doesn't actually apply to this account.
    return(NULL)
  }
  line <- grepl("token = ", cfg, fixed = TRUE)
  token <- gsub("token = ", "", cfg[line])
  if (nchar(token) == 0) {
    return(NULL)
  }
  # Drop enclosing quotes.
  gsub("\"", "", token)
}
