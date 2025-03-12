#' @export
spark_connect_method.spark_method_spark_connect <- function(
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
    ...) {
  version <- version %||% Sys.getenv("SPARK_VERSION")

  if (version == "") {
    cli_abort("Spark `version` is required, please provide")
  }

  args <- list(...)
  envname <- args$envname

  envname <- use_envname(
    backend = "pyspark",
    version = version,
    envname = envname,
    messages = TRUE,
    match_first = TRUE,
    python_version = args$python_version
  )

  if (is.null(envname)) {
    return(invisible())
  }

  pyspark <- import_check("pyspark", envname)
  pyspark_sql <- pyspark$sql
  conn <- pyspark_sql$SparkSession$builder$remote(master)
  con_class <- "connect_spark"
  master_label <- glue("Spark Connect - {master}")

  initialize_connection(
    conn = conn,
    master_label = master_label,
    con_class = con_class,
    cluster_id = NULL,
    method = method,
    config = config
  )
}

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
    ...) {
  args <- list(...)
  cluster_id <- args$cluster_id
  serverless <- args$serverless %||% FALSE
  profile <- args$profile %||% NULL
  token <- args$token
  envname <- args$envname
  silent <- args$silent %||% FALSE

  method <- method[[1]]

  token <- databricks_token(token, fail = FALSE)

  # if serverless ignore specified cluster ids
  if (serverless) {
    cluster_id <- NULL
  } else {
    cluster_id <- cluster_id %||% Sys.getenv("DATABRICKS_CLUSTER_ID")
  }

  # load python env
  envname <- use_envname(
    backend = "databricks",
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
  cluster_info <- NULL
  if (!serverless) {
    if (cluster_id != "") {
      cluster_info <- databricks_dbr_version_name(
        cluster_id = cluster_id,
        client = sdk_client,
        silent = silent
      )
      if (is.null(version)) {
        version <- cluster_info$version
      }
    }
  }

  if (!is.null(cluster_info)) {
    msg <- "{.header Connecting to} {.emph '{cluster_info$name}'}"
    msg_done <- "{.header Connected to:} {.emph '{cluster_info$name}'}"
    master_label <- glue("{cluster_info$name} ({cluster_id})")
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

initialize_connection <- function(
    conn,
    master_label,
    con_class,
    cluster_id = NULL,
    serverless = FALSE,
    method = NULL,
    config = NULL) {
  warnings <- import("warnings")
  warnings$filterwarnings(
    "ignore",
    message = "is_datetime64tz_dtype is deprecated",
    module = "pyspark"
  )
  warnings$filterwarnings(
    "ignore",
    message = "is_categorical_dtype is deprecated",
    module = "pyspark"
  )
  warnings$filterwarnings(
    "ignore",
    message = "'SparkSession' object has no attribute 'setLocalProperty'",
    module = "pyspark"
  )
  warnings$filterwarnings(
    "ignore",
    message = "Index.format is deprecated and will be removed in a future version"
  )

  session <- conn$getOrCreate()
  get_version <- try(session$version, silent = TRUE)
  if (inherits(get_version, "try-error")) databricks_dbr_error(get_version)

  # many configs cannot be applied on serverless - applies to databricks
  if (serverless) {
    config <- NULL
  }

  if (!is.null(config)) {
    config_orig <- sparklyr::spark_config()
    diffs <- setdiff(config, config_orig)
    if (length(diffs)) {
      diffs <- diffs[!grepl("sparklyr", names(diffs))]
    }
    if (!length(diffs)) {
      config <- pyspark_config()
    }
    iwalk(config, \(x, y) session$conf$set(y, x))
  }

  # do we need this `spark_context` object?
  spark_context <- list(spark_context = session)

  # browser()
  sc <- structure(
    list(
      master = master_label,
      cluster_id = cluster_id,
      config = config,
      method = method,
      session = session,
      state = spark_context,
      serverless = serverless,
      con = structure(list(), class = c("spark_connection", "DBIConnection"))
    ),
    class = c(
      con_class,
      "pyspark_connection",
      "spark_connection",
      "DBIConnection"
    )
  )

  sc
}
# setOldClass(
#   c("Hive", "spark_connection")
# )

setOldClass(
  c("connect_spark", "pyspark_connection", "spark_connection")
)

setOldClass(
  c("connect_databricks", "pyspark_connection", "spark_connection")
)

python_conn <- function(x) {
  py_object <- "python.builtin.object"
  ret <- NULL
  if (inherits(x$state$spark_context, py_object)) ret <- x$state$spark_context
  if (is.null(ret) && inherits(x[[1]]$session$sparkSession, py_object)) {
    ret <- x[[1]]$session$sparkSession
  }
  if (is.null(ret)) {
    cli_abort("Could not match Python Connection to: {class(x)}")
  }
  ret
}

build_user_agent <- function() {
  product <- NULL
  in_rstudio <- FALSE
  in_connect <- FALSE

  env_var <- Sys.getenv("SPARK_CONNECT_USER_AGENT", unset = NA)
  if (!is.na(env_var)) {
    return(env_var)
  }

  if (current_product_connect()) {
    product <- "posit-connect"
  }

  if (is.null(product)) {
    pr <- NULL
    if (check_rstudio()) {
      rstudio_version <- int_rstudio_version()
      edition <- rstudio_version$edition
      mode <- rstudio_version$mode
      version <- rstudio_version$long_version
      pr <- "rstudio"
      if (length(edition) == 0) edition <- ""

      if (length(mode) == 0) mode <- ""
      if (edition == "Professional") {
        if (mode == "server") {
          pr <- "workbench-rstudio"
        } else {
          pr <- "rstudio-pro"
        }
      }
      if (Sys.getenv("R_CONFIG_ACTIVE") == "rstudio_cloud") {
        pr <- "cloud-rstudio"
      }
    }
    if (Sys.getenv("POSITRON", unset = "0") == "1") {
      pr <- "positron"
      version <- Sys.getenv("POSITRON_VERSION", unset = NA)
    }
    if (!is.null(pr)) {
      product <- glue("posit-{pr}/{version}")
    }
  }

  glue(
    "sparklyr/{packageVersion('sparklyr')} {product}",
    .null = NULL
  )
}

int_rstudio_version <- function() {
  out <- try(RStudio.Version(), silent = TRUE)
  if (!inherits(out, "try-error")) {
    return(out)
  }
  return(NULL)
}

connection_label <- function(x) {
  x <- x[[1]]
  ret <- "Connection"
  method <- NULL
  con <- spark_connection(x)
  if (is.null(con)) {
    method <- x
  } else {
    method <- con$method
  }
  if (!is.null(method)) {
    if (method == "spark_connect" | method == "pyspark") {
      ret <- "Spark Connect"
    }
    if (method == "databricks_connect" | method == "databricks") {
      ret <- "Databricks Connect"
    }
  }
  ret
}

#' Read Spark configuration
#' @returns A list object with the initial configuration that will be used for
#' the Connect session.
#' @export
pyspark_config <- function() {
  list(
    "spark.sql.session.localRelationCacheThreshold" = 1048576L,
    "spark.sql.execution.arrow.pyspark.enabled" = "true",
    "spark.sql.execution.arrow.sparkr.enabled" = "true"
  )
}
