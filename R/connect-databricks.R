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

  host <- master %||% Sys.getenv("DATABRICKS_HOST", unset = "")
  host <- normalize_databricks_host(host)

  # if serverless ignore specified cluster ids
  if (serverless) {
    cluster_id <- NULL
  } else {
    cluster_id <- cluster_id %||% Sys.getenv("DATABRICKS_CLUSTER_ID")
  }

  # Pre-flight cluster info: if we have enough to hit the REST API directly,

  # fetch the DBR version before loading the Python env.
  cluster_info <- NULL
  if (cluster_id != "" && !serverless && is.null(version) &&
    !is.null(token) && nzchar(host)) {
    cluster_info <- databricks_dbr_info(
      cluster_id = cluster_id,
      host = host,
      token = token
    )
    version <- databricks_extract_version(cluster_info)
  }

  # Track if version was provided by user
  version_provided <- !is.null(version)

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

  # Build SDK config, delegating auth to the SDK. The only R-side auth is

  # connectcreds for Posit Connect.
  workspace <- if (nzchar(host)) host
  sdk_config <- databricks_sdk_config(
    sdk = db_sdk,
    host = host,
    token = token,
    profile = profile,
    cluster_id = if (!serverless) cluster_id,
    serverless = serverless,
    workspace = workspace
  )

  sdk_client <- db_sdk$WorkspaceClient(config = sdk_config)

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

  # Check for version mismatch and warn user
  if (!is.null(cluster_info) && !version_provided) {
    cluster_version <- databricks_extract_version(cluster_info)
    if (
      !is.null(version) && cluster_version != "" && cluster_version != version
    ) {
      if (!silent) {
        cli_div(theme = cli_colors())
        cli_alert_warning(
          paste0(
            "Using databricks.connect version {.emph {version}}, which differs from ",
            "Databricks' DBR version {.emph {cluster_version}}. If you experience instability, ",
            "consider using {.code version = \"{cluster_version}\"} to ensure a matching ",
            "version is used during the R session."
          )
        )
        cli_end()
      }
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
