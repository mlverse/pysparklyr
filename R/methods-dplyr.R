#' @importFrom dplyr sample_n slice_sample
#' @export
sample_n.tbl_pysparklyr <- function(tbl, size, replace = FALSE,
                                    weight = NULL, .env = NULL
                                    ) {
  slice_sample(
    .data = tbl,
    n = size,
    replace = replace,
    weight_by = !! enquo(weight)
    )
}

#' @export
compute.tbl_pysparklyr <- function(x, name = NULL, ...) {
  cache_query(x, name = name, storage_level = "MEMORY_AND_DISK")
}

cache_query <- function(table,
                        name = NULL,
                        storage_level = "MEMORY_AND_DISK"
                        ) {
  # https://spark.apache.org/docs/latest/sql-ref-syntax-aux-cache-cache-table.html
  if(is.null(name)) {
    name <- random_string()
  }
  x <- remote_query(table)
  query <- glue("CACHE TABLE {name} OPTIONS ('storageLevel' '{storage_level}') {x}")
  sc <- spark_connection(table)
  invoke(sc, "sql", query)
  spark_ide_connection_updated(sc, name)
  tbl(sc, name)
}

#' @export
collect.tbl_pysparklyr <- function(x, ...) {
  sc <- x[[1]]
  res <- sc$state$spark_context$sql(remote_query(x))
  to_pandas_cleaned(res)
}

#' @export
spark_dataframe.tbl_pysparklyr <- function(x, ...) {
  conn <- x[[1]]
  query <- x[[2]]
  qry <- sql_render(query, conn)
  invoke(conn, "sql", qry)
}



#' @export
sdf_copy_to.pyspark_connection <- function(sc,
                                           x,
                                           name = spark_table_name(substitute(x)),
                                           memory,
                                           repartition,
                                           overwrite,
                                           struct_columns,
                                           ...) {
  context <- sc$state$spark_context
  if (context$catalog$tableExists(name)) {
    if (overwrite) {
      context$catalog$dropTempView(name)
    } else {
      cli_abort(
        "Temp table {name} already exists, use `overwrite = TRUE` to replace"
      )
    }
  }
  col_names <- colnames(x)
  col_names <- gsub("\\.", "_", col_names)
  colnames(x) <- col_names
  df_copy <- context$createDataFrame(r_to_py(x))
  df_copy$cache()
  df_copy$createTempView(name)

  spark_ide_connection_updated(sc, name)

  tbl(src = sc, from = name)
}

#' @export
tbl.pyspark_connection <- function(src, from, ...) {
  sql_from <- as.sql(from, con = src$con)
  pyspark_obj <- src$state$spark_context$table(sql_from)
  vars <- pyspark_obj$columns
  out <- tbl_sql(
    subclass = "pysparklyr",
    src = src,
    from = sql_from,
    vars = vars
  )
  out_class <- class(out)
  new_class <- c(out_class[1], "tbl_spark", out_class[2:length(out_class)])
  class(out) <- new_class
  out
}

#' @export
tidyselect_data_has_predicates.tbl_pysparklyr <- function(x) {
  FALSE
}

#' @export
same_src.pyspark_connection <- function(x, y) {
  identical(x$master, y$master) &&
  identical(x$method, y$method) &&
  identical(x$state, y$state)
}
