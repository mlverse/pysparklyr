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
  ...
) {
  version <- version %||% Sys.getenv("SPARK_VERSION")

  if (version == "") {
    cli_abort("Spark `version` is required, please provide")
  }

  args <- list(...)
  envname <- args$envname

  envname <- use_envname(
    backend = "pyspark",
    main_library = "pyspark",
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

setOldClass(
  c("connect_spark", "pyspark_connection", "spark_connection")
)
