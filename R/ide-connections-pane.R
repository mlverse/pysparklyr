#' @export
spark_ide_objects.pyspark_connection <- function(
    con,
    catalog = NULL,
    schema = NULL,
    name = NULL,
    type = NULL) {
  catalog_python(
    con = con,
    catalog = catalog,
    schema = schema,
    name = name,
    type = type
  )
}

#' @export
spark_ide_columns.pyspark_connection <- function(
    con,
    table = NULL,
    view = NULL,
    catalog = NULL,
    schema = NULL) {
  tbl_df <- rs_get_table(con, catalog, schema, table)

  tbl_sample <- collect(head(tbl_df))

  tbl_info <- map_chr(tbl_sample, ~ paste0(rs_type(.x), " ", rs_vals(.x)))

  data.frame(
    name = names(tbl_info),
    type = tbl_info
  )
}

#' @export
spark_ide_preview.pyspark_connection <- function(
    con,
    rowLimit,
    table = NULL,
    view = NULL,
    catalog = NULL,
    schema = NULL) {
  tbl_df <- rs_get_table(con, catalog, schema, table)
  collect(head(tbl_df, rowLimit))
}

catalog_python <- function(
    con,
    catalog = NULL,
    schema = NULL,
    name = NULL,
    type = NULL) {
  df_catalogs <- data.frame()
  df_tables <- data.frame()

  limit <- as.numeric(
    Sys.getenv("SPARKLYR_CONNECTION_OBJECT_LIMIT", unset = NA)
  )
  sc_catalog <- python_conn(con)$catalog
  if (is.null(catalog) && is.null(schema)) {
    sql_catalogs <- con[["misc"]][["sql_catalogs"]] %||% "show catalogs"
    catalogs <- dbGetQuery(con, sql_catalogs)
    if (nrow(catalogs) > 0) {
      catalog_name <- ifelse("catalog" %in% colnames(catalogs), "catalog", "name")
      out <- data.frame(name = catalogs[[catalog_name]], type = "catalog")
    }
    if (!is.na(limit)) {
      out <- head(out, limit)
    }
  } else {
    if (is.null(schema)) {
      out <- rs_get_databases(con, limit, catalog)
    } else {
      if (is.null(catalog)) {
        sql_schema <- con[["misc"]][["sql_tables_schema"]] %||% "show tables in `{schema}`"
      } else {
        sql_schema <- con[["misc"]][["sql_tables_catalog_schema"]] %||% "show tables in `{catalog}`.`{schema}`"
      }
      tables <- dbGetQuery(con, glue(sql_schema))
      tables_name <- ifelse("tableName" %in% colnames(tables), "tableName", "name")
      out <- df_tables
      if (nrow(tables) > 0) {
        if("isTemporary" %in% colnames(tables)) {
          tables <- tables[!tables$isTemporary, ]
        }
        if (nrow(tables) > 0) {
          out <- data.frame(
            name = tables[[tables_name]],
            schema = schema,
            type = "table"
          )
          out$catalog <- catalog
        }
      }
      if (!is.na(limit)) {
        out <- head(out, limit)
      }
    }
  }
  out
}

rs_get_databases <- function(con, limit = NA, catalog = NULL) {
  out <- data.frame()
  if (!is.null(catalog)) {
    sql_databases <- con[["misc"]][["sql_schemas_catalog"]] %||% "show databases in `{catalog}`"
  } else {
    sql_databases <- con[["misc"]][["sql_schemas"]] %||% "show databases"
  }
  databases <- dbGetQuery(con, glue(sql_databases))
  if (nrow(databases) > 0) {
    db_names <- databases$databaseName %||% databases$namespace %||% databases$name
    out <- data.frame(name = db_names, type = "schema")
    if (!is.na(limit)) {
      out <- head(out, limit)
    }
  }
  out
}

rs_get_table <- function(con, catalog = NULL, schema = NULL, table = NULL) {
  cq <- ifelse(is.null(con$quote), "`", con$quote)
  from <- c(catalog, schema, table)
  from <- paste0(cq, from, cq, collapse = ".")
  tbl(con, I(from))
}

rs_type <- function(x) {
  class <- class(x)[[1]]
  if (class == "integer") class <- "int"
  if (class == "numeric") class <- "num"
  if (class == "POSIXct") class <- "dttm"
  if (class == "character") class <- "chr"
  class
}

rs_vals <- function(x) {
  ln <- 30
  x <- paste0(x, collapse = " ")
  if (nchar(x) > ln) {
    x <- substr(x, 1, (ln - 3))
    x <- paste0(x, "...")
  }
  x
}
