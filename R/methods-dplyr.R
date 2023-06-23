#' @importFrom dplyr collect
#' @export
collect.spark_pyobj <- function(x, ...) {
  x$pyspark_obj$toPandas()
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
  sql_from <- as.sql(from, con = src)
  pyspark_obj <- src$state$spark_context$table(sql_from)
  vars <- pyspark_obj$columns
  tbl_sql(
    subclass = "pysparklyr",
    src = src,
    from = sql_from,
    vars = vars
  )
}


