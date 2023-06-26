#' @importFrom sparklyr spark_connect_db_objects
#' @export
spark_connect_db_objects.pyspark_connection <- function(sc,
                                                        catalog = NULL,
                                                        schema = NULL,
                                                        name = NULL,
                                                        type = NULL) {
  df_catalogs <- data.frame()
  df_databases <- data.frame()
  df_tables <- data.frame()
  df_cat <- data.frame()

  sc_catalog <- python_conn(sc)$catalog
  current_catalog <- sc_catalog$currentCatalog()
  if (is.null(catalog)) {
    sc_catalog$setCurrentCatalog("spark_catalog")
    tables <- sc_catalog$listTables(dbName = "default")
    if (length(tables) > 0) {
      temps <- tables[map_lgl(tables, ~ .x$isTemporary)]
      if (length(temps) > 0) {
        df_tables <- data.frame(name = map_chr(temps, ~ .x$name))
        df_tables$type <- "table"
      }
      df_tables <- rbind(df_tables, df_cat)
    }

    catalogs <- sc_catalog$listCatalogs()
    if (length(catalogs) > 0) {
      df_catalogs <- data.frame(name = map_chr(catalogs, ~ .x$name))
      df_catalogs$type <- "catalog"
    }

    out <- rbind(df_tables, df_catalogs)
  } else {
    sc_catalog$setCurrentCatalog(catalog)
    if (is.null(schema)) {
      databases <- sc_catalog$listDatabases()
      df_databases <- data.frame(name = map_chr(databases, ~ .x$name))
      df_databases$type <- "schema"
      out <- df_databases
    } else {
      tables <- sc_catalog$listTables(dbName = schema)
      if (length(tables) > 0) {
        catalogs <- map(tables, ~ .x$catalog == catalog)
        catalogs <- map_lgl(catalogs, ~ ifelse(length(.x), .x, FALSE))
        tables <- tables[catalogs]

        schemas <- map(tables, ~ .x$namespace == schema)
        schemas <- map_lgl(schemas, ~ ifelse(length(.x), .x, FALSE))
        tables <- tables[schemas]

        if (length(tables) > 0) {
          df_tables <- data.frame(name = map_chr(tables, ~ .x$name))
          df_tables$type <- "table"
        }
      }
      out <- df_tables
    }
  }

  sc_catalog$setCurrentCatalog(current_catalog)
  out
}

#' @importFrom sparklyr spark_connect_db_columns
#' @export
spark_connect_db_columns.pyspark_connection <- function(sc,
                                                        table = NULL,
                                                        view = NULL,
                                                        catalog = NULL,
                                                        schema = NULL) {
  tbl_df <- rs_get_table(sc, catalog, schema, table)

  tbl_sample <- collect(head(tbl_df))

  tbl_info <- map_chr(tbl_sample, ~ paste0(rs_type(.x), " ", rs_vals(.x)))

  data.frame(
    name = names(tbl_info),
    type = tbl_info
  )
}

#' @importFrom sparklyr spark_connect_db_preview
#' @export
spark_connect_db_preview.pyspark_connection <- function(
    sc,
    rowLimit,
    table = NULL,
    view = NULL,
    catalog = NULL,
    schema = NULL) {
  tbl_df <- rs_get_table(sc, catalog, schema, table)
  collect(head(tbl_df, rowLimit))
}

rs_get_table <- function(sc, catalog, schema, table) {
  if (is.null(catalog)) {
    catalog <- sc$python$catalog$currentCatalog()
  }
  if (is.null(schema)) {
    schema <- sc$python$catalog$currentDatabase()
  }
  x <- in_catalog(catalog, schema, table)
  if (!sc$python$catalog$tableExists(as.sql(x, sc$con))) {
    x <- table
  }
  tbl(sc, x)
}

rs_get_table <- function(sc, catalog, schema, table) {
  context <- python_conn(sc)
  if (is.null(catalog)) {
    catalog <- context$catalog$currentCatalog()
  }
  if (is.null(schema)) {
    schema <- context$catalog$currentDatabase()
  }
  x <- in_catalog(catalog, schema, table)
  if (!context$catalog$tableExists(as.sql(x, sc$con))) {
    x <- table
  }
  tbl(sc, x)
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
