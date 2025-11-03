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
  ...
) {
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
  ...
) {
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
  ...
) {
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
  ...
) {
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
  ...
) {
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
    sc = sc,
    path = NULL,
    name = name,
    format = NULL,
    memory = memory,
    repartition = repartition,
    overwrite = overwrite,
    options = NULL,
    args = NULL,
    py_obj = read
  )
}


pyspark_read_generic <- function(sc, path, name, format, memory, repartition,
                                 overwrite, args, options = list(), py_obj = NULL) {
  opts <- c(args, options)
  rename_fields <- FALSE
  schema <- args$schema
  if (!is.null(schema)) {
    if (!inherits(schema, "list")) {
      rename_fields <- TRUE
    } else {
      abort("Complex schemas not yet supported")
    }
  }

  if (is.null(py_obj)) {
    x <- python_conn(sc)$read %>%
      py_invoke_options(options = opts) %>%
      py_invoke(format, path_expand(path))
  } else {
    x <- py_obj
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

  if (rename_fields) {
    cur_names <- x$columns
    for (i in seq_along(cur_names)) {
      x <- x$withColumnRenamed(
        existing = cur_names[[i]],
        new = schema[[i]]
      )
    }
  }

  if (memory && !sc$serverless) {
    if (repartition > 1) {
      storage_level <- import("pyspark.storagelevel")
      x$createOrReplaceTempView(name)
      x$persist(storage_level$StorageLevel$MEMORY_AND_DISK)
      out <- tbl(sc, name)
    } else {
      out <- x %>%
        tbl_pyspark_temp(sc) %>%
        cache_query(name = name)
    }
  } else {
    x$createOrReplaceTempView(name)
    out <- tbl(sc, name)
  }

  spark_ide_connection_updated(sc, name)
  out
}

gen_sdf_name <- function(path) {
  x <- path %>%
    path_file() %>%
    path_ext_remove()

  random_string(gsub("[[:punct:]]", "", x))
}
