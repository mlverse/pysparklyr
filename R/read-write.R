#' @importFrom sparklyr spark_read_csv spark_read_parquet
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

  read <- con$read$csv(
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

  finalize_read(read, sc, name, memory, repartition, overwrite)
}

#' @export
spark_read_parquet.spark_connection <- function(
    sc,
    name = NULL,
    path = name,
    options = list(),
    repartition = 0,
    memory = TRUE,
    overwrite = TRUE,
    columns = NULL,
    schema = NULL,
    ...) {
  con <- python_conn(sc)

  read <- con$read$parquet(path)

  finalize_read(read, sc, name, memory, repartition, overwrite)
}

finalize_read <- function(x, sc, name, memory, repartition, overwrite) {
  repartition <- as.integer(repartition)
  if(repartition > 0) {
    x$repartition(repartition)
  }

  if(overwrite && name %in% dbListTables(sc)) {
    dbRemoveTable(sc, name)
  }

  if(is.null(name)) {
    name <- random_string()
  }

  if(memory) {
    # temp_name <- glue("sparklyr_tmp_{random_string()}")
    # x$createTempView(temp_name)
    # temp_table <- tbl(sc, temp_name)
    # cache_query(table = temp_table, name = name)
    x$createTempView(name)
    storage_level <- import("pyspark.storagelevel")
    x$persist(storage_level$StorageLevel$MEMORY_AND_DISK)
  } else {
    x$createTempView(name)
  }
  spark_ide_connection_updated(sc, name)
  tbl(sc, name)
}
