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
  pyspark_read_generic(
    sc = sc,
    path = path,
    name = name,
    format = "csv",
    memory = memory,
    repartition = repartition,
    overwrite = overwrite,
    options = options,
    args = list(
      header = header,
      schema = columns,
      inferSchema = infer_schema,
      sep = delimiter,
      quote = quote,
      escape = escape,
      encoding = charset,
      nullValue = null_value
    )
  )
}

#' @export
spark_read_text.pyspark_connection <- function(
    sc,
    name = NULL,
    path = name,
    repartition = 0,
    memory = TRUE,
    overwrite = TRUE,
    options = list(),
    whole = FALSE,
    ...) {
  pyspark_read_generic(
    sc = sc,
    path = path,
    name = name,
    format = "text",
    memory = memory,
    repartition = repartition,
    overwrite = overwrite,
    options = options,
    args = list(
      wholetext = whole
    )
  )
}

#' @export
spark_read_json.pyspark_connection <- function(
    sc,
    name = NULL,
    path = name,
    options = list(),
    repartition = 0,
    memory = TRUE,
    overwrite = TRUE,
    columns = NULL,
    ...) {
  pyspark_read_generic(
    sc = sc,
    path = path,
    name = name,
    format = "json",
    memory = memory,
    repartition = repartition,
    overwrite = overwrite,
    options = options,
    args = list(
      columns = columns
    )
  )
}

#' @export
spark_read_orc.pyspark_connection <- function(
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
  pyspark_read_generic(
    sc = sc,
    path = path,
    name = name,
    format = "orc",
    memory = memory,
    repartition = repartition,
    overwrite = overwrite,
    options = options,
    args = list(
      columns = columns,
      schema = schema
    )
  )
}

#' @export
spark_read_parquet.pyspark_connection <- function(
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

  new_schema <- NULL
  if (!is.null(columns)) new_schema <- columns
  if (!is.null(schema)) new_schema <- schema
  if (!is.null(new_schema)) {
    sch <- con$read$schema(new_schema)
    read <- sch$parquet(path)
  } else {
    read <- con$read$parquet(path)
  }

  pyspark_read_generic(
    sc = read,
    path = NULL,
    name = name,
    format = NULL,
    memory = memory,
    repartition = repartition,
    overwrite = overwrite,
    options = NULL,
    args = NULL
  )
}


pyspark_read_generic <- function(sc, path, name, format, memory, repartition,
                                 overwrite, args, options = list()) {
  opts <- c(args, options)

  if (inherits(sc, "pyspark_connection")) {
    x <- python_conn(sc)$read %>%
      py_invoke_options(options = opts) %>%
      py_invoke(format, path_expand(path))
  } else {
    x <- sc
  }

  repartition <- as.integer(repartition)
  if (repartition > 0) {
    x$repartition(repartition)
  }

  if (overwrite && name %in% dbListTables(sc)) {
    dbRemoveTable(sc, name)
  }

  if (is.null(name) | identical(path, name)) {
    name <- gen_sdf_name(path)
  }

  x$createTempView(name)

  if (memory) {
    storage_level <- import("pyspark.storagelevel")
    x$persist(storage_level$StorageLevel$MEMORY_AND_DISK)
  }

  spark_ide_connection_updated(sc, name)
  tbl(sc, name)
}

gen_sdf_name <- function(path) {
  path %>%
    path_file() %>%
    path_ext_remove() %>%
    gsub("[[:punct:]]", "", .) %>%
    random_string()
}
