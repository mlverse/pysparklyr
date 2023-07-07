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

  if(memory) {
    if(overwrite && name %in% dbListTables(sc)) {
      dbRemoveTable(name)
    }
    out$createTempView("test")
  }

  out
}
