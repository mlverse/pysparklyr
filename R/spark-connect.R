#' @export
spark_connect_method.spark_method_spark_connect <- function(
    x,
    method,
    master = NULL,
    spark_home,
    config,
    app_name,
    version,
    hadoop_version,
    extensions,
    scala_version,
    ...) {
  py_spark_connect(
    master = master,
    method = method,
    config = config,
    ... = ...
  )
}

#' @export
spark_connect_method.spark_method_databricks_connect <- function(
    x,
    method,
    master = Sys.getenv("DATABRICKS_HOST"),
    spark_home,
    config,
    app_name,
    version,
    hadoop_version,
    extensions,
    scala_version,
    ...) {
  py_spark_connect(
    master = master,
    method = method,
    config = config,
    ...
  )
}


py_spark_connect <- function(master,
                             token = Sys.getenv("DATABRICKS_TOKEN"),
                             cluster_id = NULL,
                             method = "",
                             envname = "r-sparklyr",
                             spark_version = NULL,
                             databricks_connect_version = NULL,
                             config = list()) {
  method <- method[[1]]

  virtualenv_name <- env_version(
    envname = envname,
    spark = spark_version,
    db = databricks_connect_version
  )

  conn <- NULL

  if (method == "spark_connect") {
    pyspark <- import_check("pyspark", virtualenv_name)
    delta <- import_check("delta.pip_utils", virtualenv_name)
    pyspark_sql <- pyspark$sql
    conn <- pyspark_sql$SparkSession$builder$remote(master)
    con_class <- "connect_spark"
    master_label <- glue("Spark Connect - {master}")
  }

  if (method == "databricks_connect") {
    if (is.null(cluster_id)) {
      cluster_id <- Sys.getenv("DATABRICKS_CLUSTER_ID")
    }
    db <- import_check("databricks.connect", virtualenv_name)
    remote <- db$DatabricksSession$builder$remote(
      host = master,
      token = token,
      cluster_id = cluster_id
    )

    user_agent <- build_user_agent()

    conn <- remote$userAgent(user_agent)
    con_class <- "connect_databricks"
    master_label <- glue("Databricks Connect - Cluster: {cluster_id}")
  }

  session <- conn$getOrCreate() # pyspark.sql.connect.session.SparkSession

  require_python("pyspark", "3.4.1")
  require_python("databricks-connect", "13.2.1")
  session$conf$set("spark.sql.session.localRelationCacheThreshold", 1048576L)

  get_version <- try(session$version, silent = TRUE)

  if (inherits(get_version, "try-error")) {
    error_split <- get_version %>%
      as.character() %>%
      strsplit("\n\t") %>%
      unlist()

    error_start <- substr(error_split, 1, 9)

    status_error <- NULL
    if (any(error_start == "status = ")) {
      status_error <- error_split[error_start == "status = "]
    }

    status_details <- NULL
    if (any(error_start == "details =")) {
      status_details <- error_split[error_start == "details ="]
    }

    status_tip <- NULL
    if (grepl("UNAVAILABLE", status_error)) {
      status_tip <- "Possible cause = The cluster is not running, or not accessible"
    }
    if (grepl("FAILED_PRECONDITION", status_error)) {
      status_tip <- "Possible cause = The cluster is initializing. Try again later"
    }
    rlang::abort(
      c(
        "Spark connection error",
        status_tip,
        status_error,
        status_details
      )
    )
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
      con = structure(list(), class = c("spark_connection", "DBIConnection"))
    ),
    class = c(con_class, "pyspark_connection", "spark_connection", "DBIConnection")
  )

  sc
}
setOldClass(
  c("Hive", "spark_connection")
)


setOldClass(
  c("connect_spark", "pyspark_connection", "spark_connection")
)

setOldClass(
  c("connect_databricks", "pyspark_connection", "spark_connection")
)

env_version <- function(envname, spark = NULL, db = NULL) {
  ver <- envname
  if (!is.null(spark) | !is.null(db)) {
    if (!is.null(db)) {
      ver <- glue("{envname}-db-{db}")
    }
    if (!is.null(spark) & ver == envname) {
      ver <- glue("{envname}-pyspark-{spark}")
    }
  }
  ver
}

python_conn <- function(x) {
  x$state$spark_context
}

build_user_agent <- function() {
  product <- NULL
  in_rstudio <- FALSE
  in_connect <- FALSE

  if (Sys.getenv("RSTUDIO_PRODUCT") == "CONNECT") {
    product <- "posit-connect"
  }

  if (is.null(product)) {
    check_rstudio <- try(RStudio.Version(), silent = TRUE)
    if (!inherits(check_rstudio, "try-error")) {
      prod <- "rstudio"

      edition <- check_rstudio$edition
      if (length(edition) == 0) edition <- ""

      mod <- check_rstudio$mode
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

      product <- glue("posit-{prod}/{check_rstudio$long_version}")
    }
  }

  glue(
    paste(
      "sparklyr/{packageVersion('sparklyr')}",
      product
    )
  )
}


cluster_dbr_version <- function(cluster_id,
                                host = Sys.getenv("DATABRICKS_HOST"),
                                token = Sys.getenv("DATABRICKS_TOKEN")
                                ) {
  cluster_info <- paste0(
    host,
    "/api/2.0/clusters/get"
  ) %>%
    request() %>%
    req_auth_bearer_token(token) %>%
    req_body_json(list(cluster_id = cluster_id)) %>%
    req_perform() %>%
    resp_body_json()

  sp_version <- cluster_info$spark_version

  sp_sep <- unlist(strsplit(sp_version, "\\."))

  paste0(sp_sep[1], ".", sp_sep[2])
}
