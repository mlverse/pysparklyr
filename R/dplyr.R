#' @export
head.tbl_pyspark <- function(x, n = 6L, ...) {
  if (!is.null(python_sdf(x))) {
    sdf <- tbl_pyspark_sdf(x)
    sdf_limit <- sdf$limit(as.integer(n))
    x <- python_obj_tbl_set(x, sdf_limit)
    # x[[2]] <- lazy_select_query(x[[2]], limit = n)
    NextMethod()
  } else {
    NextMethod()
  }
}

#' @export
sample_n.tbl_pyspark <- function(
    tbl,
    size,
    replace = FALSE,
    weight = NULL,
    .env = NULL, ...) {
  slice_sample(
    .data = tbl,
    n = size,
    replace = replace,
    weight_by = !!enquo(weight)
  )
}

#' @export
sample_frac.tbl_pyspark <- function(tbl, size = 1, replace = FALSE,
                                    weight = NULL, .env = NULL, ...) {
  weight <- enquo(weight)
  if (!quo_is_null(weight)) {
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
                        storage_level = "MEMORY_AND_DISK") {
  # https://spark.apache.org/docs/latest/sql-ref-syntax-aux-cache-cache-table.html
  if (is.null(name)) {
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
  qry <- query %>%
    sql_render(conn) %>%
    query_cleanup(conn)
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
  if (repartition > 0) {
    df_copy$createTempView(name)
    df_copy$repartition(repartition)
    if (memory && !sc$serverless) {
      storage_level <- import("pyspark.storagelevel")
      df_copy$persist(storage_level$StorageLevel$MEMORY_AND_DISK)
    }
    out <- tbl(src = sc, from = name)
  } else {
    out <- df_copy %>%
      tbl_pyspark_temp(sc)
    if (memory && !sc$serverless) {
      out <- cache_query(table = out, name = name)
    }
  }

  spark_ide_connection_updated(sc, name)

  out
}

#' @export
tbl.pyspark_connection <- function(src, from, ...) {
  if (inherits(from, "AsIs")) {
    sql_from <- from
  } else {
    sql_from <- as.sql(from, con = src$con)
  }
  con <- python_conn(src)
  pyspark_obj <- con$table(sql_from)
  vars <- as.character(pyspark_obj$columns)
  src <- python_obj_con_set(src, pyspark_obj)
  out <- tbl_sql(
    subclass = "pyspark",
    src = src,
    from = from,
    vars = vars,
    ...
  )
  out_class <- class(out)
  new_class <- c(out_class[1], "tbl_spark", out_class[2:length(out_class)])
  class(out) <- new_class
  out
}

#' @export
tbl_ptype.tbl_pyspark <- function(.data) {
  abort("Predicates are not supported with this back-end")
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
  out <- python_sdf(x)
  if (is.null(out)) {
    con <- python_conn(x[[1]])
    qry <- x %>%
      remote_query() %>%
      query_cleanup(con)
    out <- con$sql(qry)
  }
  out
}

tbl_temp_name <- function() glue("{temp_prefix()}{random_string()}")

#' @export
sdf_register.spark_pyobj <- function(x, name = NULL) {
  # Attempting to cache a data frame with 0 columns returns an error.
  # So it returns nothing when this is the case (#110)
  x_obj <- python_obj_get(x)
  if (inherits(x_obj, "pyspark.sql.connect.dataframe.DataFrame")) {
    if (length(x_obj$columns) == 0) {
      return(invisible())
    }
  }
  sc <- spark_connection(x)
  tbl_pyspark_temp(
    x = x_obj,
    conn = sc,
    tmp_name = name
  )
}

python_sdf <- function(x) {
  pyobj <- python_obj_get(x)
  class_pyobj <- class(pyobj)
  # Removing remote name check for now
  # name <- remote_name(x)
  out <- NULL
  # Removing remote name check for now
  # if (!is.null(name) && any(grepl("dataframe", class_pyobj))) {
  if (any(grepl("dataframe", class_pyobj))) {
    out <- pyobj
  }
  out
}

python_obj_get <- function(x) {
  UseMethod("python_obj_get")
}

#' @export
python_obj_get.default <- function(x) {
  if (inherits(x, "character")) {
    return(x)
  }
  py_x <- try(get_spark_pyobj(x), silent = TRUE)
  if (!inherits(py_x, "try-error")) {
    return(py_x[["pyspark_obj"]])
  } else {
    sc <- spark_connection(x)
    if (inherits(sc$session, "python.builtin.object")) {
      return(sc$session)
    }
  }
}

#' @export
python_obj_get.python.builtin.object <- function(x) {
  x
}

#' @export
python_obj_get.spark_pyobj <- function(x) {
  x[["pyspark_obj"]]
}

#' @export
python_obj_get.ml_connect_model <- function(x) {
  x[["pipeline"]][["pyspark_obj"]]
}

#' @export
python_obj_get.ml_connect_pipeline <- function(x) {
  x[[".jobj"]][["pyspark_obj"]]
}

#' @export
python_obj_get.ml_connect_pipeline_model <- function(x) {
  x[[".jobj"]]
}

#' @export
python_obj_get.tbl_pyspark <- function(x) {
  x[["src"]][["session"]]
}


python_obj_con_set <- function(sc, obj) {
  sc$session <- obj
  sc
}

python_obj_tbl_set <- function(tbl, obj) {
  conn <- spark_connection(tbl)
  sc <- python_obj_con_set(conn, obj)
  tbl[[1]] <- sc
  tbl
}

tbl_pyspark_temp <- function(x, conn, tmp_name = NULL) {
  sc <- spark_connection(conn)
  if (is.null(tmp_name)) {
    tmp_name <- tbl_temp_name()
  }
  py_x <- python_obj_get(x)
  py_x$createOrReplaceTempView(tmp_name)
  tbl(sc, tmp_name)
}

setOldClass(c("tbl_pyspark", "tbl_spark"))

#' @export
`[.tbl_pyspark` <- function(x, i) {
  # this is defined to match the interface to sparklyr::`[.tbl_spark`. But it really
  # should be more flexible, taking row specs, multiple args, etc. matching
  # semantics of R dataframes and take advantage of
  # reticulate::`[.python.builtin.object` for constructing slices, etc.
  if (is.null(i)) {
    # special case, since pyspark has no "emptyDataFrame" method to invoke
    sc <- spark_connection(x)

    pyspark.sql.types <- reticulate::import("pyspark.sql.types")
    ss <- x$src$state$spark_context # SparkSession obj
    edf <- ss$createDataFrame(list(), pyspark.sql.types$StructType(list()))

    tmp_name <- tbl_temp_name()
    edf$createOrReplaceTempView(tmp_name)
    return(tbl(sc, tmp_name))
  }
  NextMethod()
}

query_cleanup <- function(x, con) {
  if (inherits(con, "connect_snowflake")) {
    x <- gsub("`", "", x)
  }
  x
}
