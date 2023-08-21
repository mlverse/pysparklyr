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
    ... = ...
  )
}


py_spark_connect <- function(master,
                             token = Sys.getenv("DATABRICKS_TOKEN"),
                             cluster_id = NULL,
                             method = "",
                             virtualenv_name = "r-sparklyr",
                             spark_version = NULL,
                             databricks_connect_version = NULL,
                             config = list()) {
  method <- method[[1]]

  virtualenv_name <- env_version(
    envname = virtualenv_name,
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

  python <- conn$getOrCreate()

  get_version <- try(python$version, silent = TRUE)

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

  spark_context <- list(spark_context = python)

  sc <- structure(
    list(
      master = master_label,
      cluster_id = cluster_id,
      config = config,
      method = method,
      python_obj = python,
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

python_obj_get <- function(x) {
  sc <- spark_connection(x)
  sc$python_obj
}

python_obj_con_set <- function(sc, obj) {
  sc$python_obj <- obj
  sc
}

python_obj_tbl_set <- function(tbl, obj) {
  conn <- spark_connection(tbl)
  sc <- python_obj_con_set(conn, obj)
  tbl[[1]] <- sc
  tbl
}

python_sdf <- function(x) {
  pyobj <- python_obj_get(x)
  class_pyobj <- class(pyobj)
  name <- remote_name(x)
  out <- NULL
  if (!is.null(name) && any(grepl("dataframe", class_pyobj))) {
    out <- pyobj
  }
  out
}


build_user_agent <- function() {
  product <- NULL
  in_rstudio <- FALSE
  in_connect <- FALSE

  check_rstudio <- try(RStudio.Version(), silent = TRUE)
  if (!inherits(check_rstudio, "try-error")) {
    in_rstudio <- TRUE
  }

  if(Sys.getenv("RSTUDIO_PRODUCT") == "CONNECT") {
    in_connect <- TRUE
  }

  if(in_connect) {
    product <- "posit-connect"
  }

  if (in_rstudio && !in_connect) {
    edition <- check_rstudio$edition
    if(length(edition) == 0) edition <- ""

    mod <- check_rstudio$mode
    if(length(mod) == 0) mod <- ""

    if(edition == "Professional") {
      if(mod == "server") {
        prod <- "workbench-rstudio"
      } else {
        prod <- "rstudio-pro"
      }
    } else {
      prod <- "rstudio"
    }
    product <- glue("posit-{prod}/{check_rstudio$long_version}")
  }

  glue(
    paste(
      "sparklyr/{packageVersion('sparklyr')}",
      product
    )
  )
}
