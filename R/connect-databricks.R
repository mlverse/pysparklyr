#' @export
spark_connect_method.spark_method_databricks_connect <- function(
  x,
  method,
  master,
  spark_home,
  config = pyspark_config(),
  app_name,
  version = NULL,
  hadoop_version,
  extensions,
  scala_version,
  ...
) {
  args <- list(...)
  cluster_id <- args$cluster_id
  serverless <- args$serverless %||% FALSE
  profile <- args$profile %||% NULL
  token <- args$token
  envname <- args$envname
  silent <- args$silent %||% FALSE

  method <- method[[1]]

  master <- databricks_host(master, fail = FALSE)
  token <- databricks_token(token, fail = FALSE)

  # if serverless ignore specified cluster ids
  if (serverless) {
    cluster_id <- NULL
  } else {
    cluster_id <- cluster_id %||% Sys.getenv("DATABRICKS_CLUSTER_ID")
  }

  cluster_info <- NULL
  if (cluster_id != "" && !serverless && is.null(version) && !is.null(token)) {
    cluster_info <- databricks_dbr_info(
      cluster_id = cluster_id,
      host = master,
      token = token
    )
    version <- databricks_extract_version(cluster_info)
  }

  # load python env
  envname <- use_envname(
    backend = "databricks",
    main_library = "databricks.connect",
    version = version,
    envname = envname,
    messages = !silent,
    match_first = FALSE,
    ask_if_not_installed = FALSE,
    python_version = args$python_version
  )

  if (is.null(envname)) {
    return(invisible)
  }

  # load python libs
  dbc <- import_check("databricks.connect", envname, silent)
  db_sdk <- import_check("databricks.sdk", envname, silent = TRUE)

  if (is.null(token) || token == "") {
    sdk_config <- db_sdk$core$Config()
    token <- sdk_config$token %||% ""
  }

  # create workspace client
  sdk_client <- databricks_sdk_client(
    sdk = db_sdk,
    host = master,
    serverless = serverless,
    cluster_id = cluster_id,
    token = token,
    profile = profile
  )

  # if serverless override cluster_id and set to `NULL`
  if (!serverless) {
    if (cluster_id != "" && is.null(cluster_info)) {
      cluster_info <- databricks_dbr_info(
        cluster_id = cluster_id,
        client = sdk_client,
        silent = silent
      )
    }
  }

  if (!is.null(cluster_info)) {
    msg <- "{.header Connecting to} {.emph '{cluster_info$cluster_name}'}"
    msg_done <- "{.header Connected to:} {.emph '{cluster_info$cluster_name}'}"
    master_label <- glue("{cluster_info$cluster_name} ({cluster_id})")
  } else if (!serverless) {
    msg <- "{.header Connecting to} {.emph '{cluster_id}'}"
    msg_done <- "{.header Connected to:} '{.emph '{cluster_id}'}'"
    master_label <- glue("Databricks Connect - Cluster: {cluster_id}")
  } else if (serverless) {
    msg <- "{.header Connecting to} {.emph serverless}"
    msg_done <- "{.header Connected to:} '{.emph serverless}'"
    master_label <- glue("Databricks Connect - Cluster: serverless")
  }

  if (!silent) {
    cli_div(theme = cli_colors())
    cli_progress_step(msg, msg_done)
  }

  # build databricks session connection
  user_agent <- build_user_agent()
  conn <- dbc$DatabricksSession$builder$sdkConfig(sdk_client$config)$userAgent(
    user_agent
  )

  if (!silent) {
    cli_progress_done()
    cli_end()
  }

  initialize_connection(
    conn = conn,
    master_label = master_label,
    con_class = "connect_databricks",
    cluster_id = cluster_id,
    serverless = serverless,
    method = method,
    config = config
  )
}

setOldClass(
  c("connect_databricks", "pyspark_connection", "spark_connection")
)
