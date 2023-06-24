#' @importFrom dplyr collect
#' @export
collect.spark_pyobj <- function(x, ...) {
  x$pyspark_obj$toPandas()
}

#' @importFrom dplyr collect
#' @export
collect.tbl_pysparklyr <- function(x, ...) {
  sc <- x[[1]]
  res <- sc$state$spark_context$sql(remote_query(x))
  res$toPandas()
}

#' @export
spark_dataframe.tbl_pysparklyr <- function(x, ...) {
  conn <- x[[1]]
  query <- x[[2]]
  qry <- sql_render(query, conn)
  invoke(conn, "sql", qry)
}

#' @importFrom sparklyr sdf_copy_to
#' @export
sdf_copy_to.pyspark_connection <- function(sc,
                                           x,
                                           name,
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
  df_copy <- context$createDataFrame(r_to_py(x))
  df_copy$cache()
  df_copy$createTempView(name)
  tbl(src = sc, from = name)
}

#' @importFrom dplyr tbl
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


