#' @importFrom sparklyr spark_connect_method
#' @export
spark_connect_method.spark_method_spark_connect <- function(
    x,
    method,
    master,
    spark_home,
    config,
    app_name,
    version,
    hadoop_version,
    extensions,
    scala_version,
    ...
) {
  py_spark_connect(host = master, method = method, config = config)
}


py_spark_connect <- function(host,
                             token = Sys.getenv("DATABRICKS_TOKEN"),
                             cluster_id = NULL,
                             method = c("auto", "spark_connect", "db_connect", "local"),
                             virtualenv_name = "r-sparklyr",
                             spark_version = NULL,
                             databricks_connect_version = NULL,
                             config = list()
                             ) {
  master <- ""
  remote <- ""

  method <- method[[1]]

  if (method == "auto") {
    if (is.null(cluster_id) & grepl("sc://", host)) {
      method <- "spark_connect"
    }
    if (!is.null(cluster_id)) {
      method <- "db_connect"
    }
    if(substr(host, 1, 5) == "local") {
      method <- "local"
      master <- "local"
    }
  }

  virtualenv_name <- env_version(
    envname = virtualenv_name,
    spark = spark_version,
    db = databricks_connect_version
  )

  if (method == "spark_connect") {
    pyspark <- import_check("pyspark", virtualenv_name)
    pyspark_sql <- pyspark$sql
    remote <- pyspark_sql$SparkSession$builder$remote(host)
    python <- remote$getOrCreate()
    con_class <- "connect_spark"
    remote <- host
  }

  if (method == "db_connect") {
    db <- import_check("databricks.connect", virtualenv_name)
    remote <- db$DatabricksSession$builder$remote(
      host = host,
      token = token,
      cluster_id = cluster_id
    )
    python <- remote$getOrCreate()
    con_class <- "connect_databricks"
    remote <- host
  }

  sc <- structure(
    list(
      master = master,
      remote = remote,
      cluster_id = cluster_id,
      config = config,
      method = method,
      python = python,
      con = structure(list(), class = c("Hive", "DBIConnection"))
    ),
    class = c("spark_connection", "spark_pyspark_connection", con_class)
  )

  sc
}

#' @importFrom sparklyr connection_is_open
#' @export
connection_is_open.connect_spark <- function(sc) {
  TRUE
}

#' @importFrom sparklyr spark_connection
#' @export
spark_connection.connect_spark <- function(sc) {
  sc
}

env_version <- function(envname, spark = NULL, db = NULL) {
  ver <- envname
  if(!is.null(spark) | !is.null(db)) {
    if(!is.null(db)) {
      ver <- glue("{envname}-db-{db}")
    }
    if(!is.null(spark) & ver == envname) {
      ver <- glue("{envname}-pyspark-{spark}")
    }
  }
  ver
}

#' @importFrom sparklyr invoke
#' @export
invoke <- function(jobj, method, ...) {
  method <- jobj$python[[method]]
  res <- rlang::exec(method, ...)
  res$toPandas()
}
