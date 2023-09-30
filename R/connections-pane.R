#' @export
spark_ide_objects.pyspark_connection <- function(
    con,
    catalog = NULL,
    schema = NULL,
    name = NULL,
    type = NULL) {
  df_catalogs <- data.frame()
  df_databases <- data.frame()
  df_tables <- data.frame()
  df_cat <- data.frame()

  limit <- as.numeric(
    Sys.getenv("SPARKLYR_CONNECTION_OBJECT_LIMIT", unset = 1000)
  )

  sc_catalog <- python_conn(con)$catalog
  current_catalog <- sc_catalog$currentCatalog()
  if (is.null(catalog)) {
    sc_catalog$setCurrentCatalog("spark_catalog")
    tables <- sc_catalog$listTables(dbName = "default")
    if (length(tables) > 0) {
      temps <- tables[map_lgl(tables, ~ .x$isTemporary)]
      df_tables <- temps %>%
        rs_tables()
    }

    catalogs <- sc_catalog$listCatalogs()
    if (length(catalogs) > 0) {
      df_catalogs <- data.frame(name = map_chr(catalogs, ~ .x$name))
      df_catalogs$type <- "catalog"
    }
    comb <- rbind(df_tables, df_catalogs)
    out <- head(comb, limit)
  } else {
    sc_catalog$setCurrentCatalog(catalog)
    if (is.null(schema)) {
      databases <- sc_catalog$listDatabases()
      df_databases <- data.frame(name = map_chr(databases, ~ .x$name))
      df_databases$type <- "schema"
      out <- head(df_databases, limit)
    } else {
      tables <- sc_catalog$listTables(dbName = schema)
      if (length(tables) > 0) {
        catalogs <- map(tables, ~ .x$catalog == catalog)
        catalogs <- map_lgl(catalogs, ~ ifelse(length(.x), .x, FALSE))
        tables <- tables[catalogs]

        schemas <- map(tables, ~ .x$namespace == schema)
        schemas <- map_lgl(schemas, ~ ifelse(length(.x), .x, FALSE))
        tables <- tables[schemas]
        df_tables <- rs_tables(tables)
      }
      out <- head(df_tables, limit)
    }
  }

  sc_catalog$setCurrentCatalog(current_catalog)
  out
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

rs_get_table <- function(con, catalog, schema, table) {
  context <- python_conn(con)
  if (is.null(catalog)) {
    catalog <- context$catalog$currentCatalog()
  }
  if (is.null(schema)) {
    schema <- context$catalog$currentDatabase()
  }
  x <- in_catalog(catalog, schema, table)
  if (!context$catalog$tableExists(as.sql(x, con$con))) {
    x <- table
  }
  tbl(con, x)
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

rs_tables <- function(x) {
  out <- data.frame()
  if (length(x) > 0) {
    table_names <- map_chr(x, ~ .x$name)
    final_names <- table_names[!grepl(temp_prefix(), table_names)]
    out <- data.frame(name = final_names)
    out$type <- "table"
  }
  out
}
