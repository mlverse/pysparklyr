#' @export
spark_connect_method.spark_method_spark_connect <- function(
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
    match_first = TRUE
  )

  if(is.null(envname)) {
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
    config,
    app_name,
    version = NULL,
    hadoop_version,
    extensions,
    scala_version,
    ...) {
  args <- list(...)
  cluster_id <- args$cluster_id
  token <- args$token
  envname <- args$envname
  host_sanitize <- args$host_sanitize %||% TRUE
  silent <- args$silent %||% FALSE

  method <- method[[1]]
  token <- databricks_token(token, fail = FALSE)
  cluster_id <- cluster_id %||% Sys.getenv("DATABRICKS_CLUSTER_ID")
  master <- databricks_host(master, fail = FALSE)
  if (host_sanitize && master != "") {
    master <- sanitize_host(master, silent)
  }

  cluster_info <- NULL
  if (cluster_id != "" && master != "" && token != "") {
    cluster_info <- databricks_dbr_version_name(
      cluster_id = cluster_id,
      host =  master,
      token = token,
      silent = silent
      )
    if (is.null(version)) {
      version <- cluster_info$version
    }
  }

  envname <- use_envname(
    backend = "databricks",
    version = version,
    envname = envname,
    messages = !silent,
    match_first = TRUE,
    main_library = "databricks.connect"
  )

  if(is.null(envname)) {
    return(invisible)
  }

  db <- import_check("databricks.connect", envname, silent)

  if (!is.null(cluster_info)) {
    msg <- "{.header Connecting to} {.emph '{cluster_info$name}'}"
    msg_done <- "{.header Connected to:} {.emph '{cluster_info$name}'}"
    master_label <- glue("{cluster_info$name} ({cluster_id})")
  } else {
    msg <- "{.header Connecting to} {.emph '{cluster_id}'}"
    msg_done <- "{.header Connected to:} '{.emph '{cluster_id}'}'"
    master_label <- glue("Databricks Connect - Cluster: {cluster_id}")
  }

  if(!silent) {
    cli_div(theme = cli_colors())
    cli_progress_step(msg, msg_done)
  }

  remote_args <- list()
  if (master != "") remote_args$host <- master
  if (token != "") remote_args$token <- token
  if (cluster_id != "") remote_args$cluster_id <- cluster_id

  databricks_session <- function(...) {
    user_agent <- build_user_agent()
    db$DatabricksSession$builder$remote(...)$userAgent(user_agent)
  }

  conn <- exec(databricks_session, !!!remote_args)

  if(!silent) {
    cli_progress_done()
    cli_end()
  }

  initialize_connection(
    conn = conn,
    master_label = master_label,
    con_class = "connect_databricks",
    cluster_id = cluster_id,
    method = method,
    config = config
  )
}

initialize_connection <- function(
    conn,
    master_label,
    con_class,
    cluster_id = NULL,
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
  session <- conn$getOrCreate()
  get_version <- try(session$version, silent = TRUE)
  if (inherits(get_version, "try-error")) databricks_dbr_error(get_version)
  session$conf$set("spark.sql.session.localRelationCacheThreshold", 1048576L)

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
      con = structure(list(), class = c("spark_connection", "DBIConnection"))
    ),
    class = c(con_class, "pyspark_connection", "spark_connection", "DBIConnection")
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
    if (check_rstudio()) {
      rstudio_version <- int_rstudio_version()
      prod <- "rstudio"
      edition <- rstudio_version$edition
      if (length(edition) == 0) edition <- ""
      mod <- rstudio_version$mode
      if (length(mod) == 0) mod <- ""
      if (edition == "Professional") {
        if (mod == "server") {
          prod <- "workbench-rstudio"
        } else {
          prod <- "rstudio-pro"
        }
      }
      if (Sys.getenv("R_CONFIG_ACTIVE") == "rstudio_cloud") {
        prod <- "cloud-rstudio"
      }
      product <- glue("posit-{prod}/{rstudio_version$long_version}")
    }
  }

  glue(
    paste(
      "sparklyr/{packageVersion('sparklyr')}",
      product
    )
  )
}

int_rstudio_version <- function() {
  out <- try(RStudio.Version(), silent = TRUE)
  if(!inherits(out, "try-error")) return(out)
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
