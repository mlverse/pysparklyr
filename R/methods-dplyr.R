#' @export
sample_n.tbl_pyspark <- function(tbl, size, replace = FALSE,
                                    weight = NULL, .env = NULL, ...
                                    ) {
  slice_sample(
    .data = tbl,
    n = size,
    replace = replace,
    weight_by = !! enquo(weight)
    )
}

#' @export
sample_frac.tbl_pyspark <- function(tbl, size = 1, replace = FALSE,
                                       weight = NULL, .env = NULL, ...
                                       ){
  weight <- enquo(weight)
  if(!quo_is_null(weight)) {
    abort("`weight` is not supported in this Spark connection")
  }
  df <- tbl_pyspark_sdf(tbl)
  sampled <- df$sample(fraction = size, withReplacement = TRUE)
  tbl_pyspark_temp(sampled, tbl)
}


#' @export
compute.tbl_pyspark <- function(x, name = NULL, ...) {
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
collect.tbl_pyspark <- function(x, ...) {
  x %>%
    tbl_pyspark_sdf() %>%
    to_pandas_cleaned()
}

#' @export
spark_dataframe.tbl_pyspark <- function(x, ...) {
  conn <- x[[1]]
  query <- x[[2]]
  qry <- sql_render(query, conn)
  invoke(conn, "sql", qry)
}

#' @export
sdf_copy_to.pyspark_connection <- function(sc,
                                           x,
                                           name = spark_table_name(substitute(x)),
                                           memory = TRUE,
                                           repartition = 0,
                                           overwrite = FALSE,
                                           struct_columns,
                                           ...) {
  context <- python_conn(sc)
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


  repartition <- as.integer(repartition)
  if(repartition > 0) {
    df_copy$createTempView(name)
    df_copy$repartition(repartition)
    if(memory) {
      storage_level <- import("pyspark.storagelevel")
      df_copy$persist(storage_level$StorageLevel$MEMORY_AND_DISK)
    }
    out <- tbl(src = sc, from = name)
  } else {
    out <- df_copy %>%
      tbl_pyspark_temp(sc) %>%
      cache_query(name = name)
  }

  spark_ide_connection_updated(sc, name)

  out
}

#' @export
tbl.pyspark_connection <- function(src, from, ...) {
  sql_from <- as.sql(from, con = src$con)
  con <- python_conn(src)
  pyspark_obj <- con$table(sql_from)
  vars <- pyspark_obj$columns
  out <- tbl_sql(
    subclass = "pyspark",
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
tbl_ptype.tbl_pyspark <- function(.data) {
  abort("Predicates are not supported in thie back-end")
}

#' @export
tidyselect_data_has_predicates.tbl_pyspark <- function(x) {
  FALSE
}

#' @export
same_src.pyspark_connection <- function(x, y) {
  identical(x$master, y$master) &&
  identical(x$method, y$method) &&
  identical(x$state, y$state)
}

tbl_pyspark_sdf <- function(x) {
  con <- python_conn(x[[1]])
  qry <- remote_query(x)
  con$sql(qry)
}

tbl_temp_name <- function() glue("{temp_prefix()}{random_string()}")

tbl_pyspark_temp <- function(x, conn, tmp_name = NULL) {
  sc <- spark_connection(conn)
  if(is.null(tmp_name)) {
    tmp_name <- tbl_temp_name()
  }
  x$createOrReplaceTempView(tmp_name)
  tbl(sc, tmp_name)
}

setOldClass(c("tbl_pyspark", "tbl_spark"))
