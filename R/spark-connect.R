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

  if (method == "spark_connect") {
    pyspark <- import_check("pyspark", virtualenv_name)
    pyspark_sql <- pyspark$sql
    remote <- pyspark_sql$SparkSession$builder$remote(master)
    python <- remote$getOrCreate()
    con_class <- "connect_spark"
    master_label <- glue("Spark Connect - {master}")
  }

  if (method == "db_connect") {
    db <- import_check("databricks.connect", virtualenv_name)
    remote <- db$DatabricksSession$builder$remote(
      host = master,
      token = token,
      cluster_id = cluster_id
    )
    python <- remote$getOrCreate()
    con_class <- "connect_databricks"
    master_label <- glue("Databricks Connect - Cluster: {cluster_id}")
  }

  spark_context <- list(spark_context = python)

  sc <- structure(
    list(
      master = master_label,
      cluster_id = cluster_id,
      config = config,
      method = method,
      state = spark_context,
      con = structure(list(), class = c("spark_connection", "Hive", "DBIConnection"))
    ),
    class = c(con_class, "pyspark_connection", "spark_connection", "DBIConnection")
  )

  sc
}
methods::setOldClass(
  c("connect_spark", "pyspark_connection", "spark_connection")
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
