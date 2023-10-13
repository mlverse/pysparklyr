#' @export
spark_ide_objects.pyspark_connection <- function(
    con,
    catalog = NULL,
    schema = NULL,
    name = NULL,
    type = NULL) {

  env_var_sel <- Sys.getenv("SPARKLYR_RSTUDIO_CP_VIEW", unset = NA)

  if(is.na(env_var_sel)) {
    ret <- catalog_python(
      con = con,
      catalog = catalog,
      schema = schema,
      name = name,
      type = type
    )
  } else {
    if(env_var_sel == "uc_only") {
      # Sys.setenv("SPARKLYR_RSTUDIO_CP_VIEW" = "uc_only")
      ret <- catalog_sql(
        con = con,
        catalog = catalog,
        schema = schema,
        name = name,
        type = type
      )
    }
  }

  ret
}

catalog_python <- function(
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
    Sys.getenv("SPARKLYR_CONNECTION_OBJECT_LIMIT", unset = 100)
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


catalog_sql <- function(
    con,
    catalog = NULL,
    schema = NULL,
    name = NULL,
    type = NULL) {

  limit <- as.numeric(
    Sys.getenv("SPARKLYR_CONNECTION_OBJECT_LIMIT", unset = 100)
  )

  if(is.null(catalog)) {
    all_catalogs <- tbl(
      src = con,
      in_catalog("system", "information_schema", "catalogs")
      )

    get_catalogs <- all_catalogs %>%
      select(catalog_name, comment) %>%
      head(limit) %>%
      collect()

    df_catalogs <- get_catalogs %>%
      mutate(
        name = catalog_name,
        type = "catalog"
      ) %>%
      select(name, type) %>%
      as.data.frame()

    out <- df_catalogs
  }

  if(is.null(schema) && !is.null(catalog)) {
    all_schema <- tbl(
      src = con,
      in_catalog("system", "information_schema", "schemata")
      )

    get_schema <- all_schema %>%
      filter(catalog_name == catalog) %>%
      select(schema_name, comment) %>%
      head(limit) %>%
      collect()

    df_schema <- get_schema %>%
      mutate(
        name = schema_name,
        type = "schema"
      ) %>%
      select(name, type) %>%
      as.data.frame()

    out <- df_schema
  }

  if(!is.null(schema) && !is.null(catalog)) {
    all_tables <- tbl(
      src = con,
      in_catalog("system", "information_schema", "tables")
      )

    get_tables <- all_tables %>%
      filter(
        table_catalog == catalog,
        table_schema == schema
      ) %>%
      select(table_name) %>%
      head(limit) %>%
      collect()

    df_tables <- get_tables %>%
      mutate(
        name = table_name,
        type = "table"
      ) %>%
      select(name, type) %>%
      as.data.frame()

    out <- df_tables
  }


  out
}

globalVariables(c(
  "catalog_name", "schema_name", "table_catalog",
  "table_name", "table_schema")
  )
