#' @importFrom sparklyr spark_read_csv
#' @export
spark_read_csv.pyspark_connection <- function(
    sc,
    name = NULL,
    path = name,
    header = TRUE,
    columns = NULL,
    infer_schema = is.null(columns),
    delimiter = ",",
    quote = "\"",
    escape = "\\",
    charset = "UTF-8",
    null_value = NULL,
    options = list(),
    repartition = 0,
    memory = TRUE,
    overwrite = TRUE,
    ...) {

  con <- python_conn(sc)

  out <- con$read$csv(
    path = path,
    header = header,
    schema = columns,
    inferSchema = infer_schema,
    sep = delimiter,
    quote = quote,
    escape = escape,
    encoding = charset,
    nullValue = null_value
    )

  repartition <- as.integer(repartition)
  if(repartition > 0) {
    out$repartition(repartition)
  }

  if(overwrite && name %in% dbListTables(sc)) {
    dbRemoveTable(sc, name)
  }

  if(is.null(name)) {
    name <- random_string()
  }

  if(memory) {
    # temp_name <- glue("sparklyr_tmp_{random_string()}")
    # out$createTempView(temp_name)
    # temp_table <- tbl(sc, temp_name)
    # cache_query(table = temp_table, name = name)
    out$createTempView(name)
    storage_level <- import("pyspark.storagelevel")
    out$persist(storage_level$StorageLevel$MEMORY_AND_DISK)
  } else {
    out$createTempView(name)
  }
  spark_ide_connection_updated(sc, name)
  tbl(sc, name)
}
