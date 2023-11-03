#' @export
spark_ide_objects.pyspark_connection <- function(
    con,
    catalog = NULL,
    schema = NULL,
    name = NULL,
    type = NULL) {
  env_var_sel <- Sys.getenv("SPARKLYR_RSTUDIO_CP_VIEW", unset = NA)

  if (is.na(env_var_sel)) {
    ret <- catalog_python(
      con = con,
      catalog = catalog,
      schema = schema,
      name = name,
      type = type
    )
  } else {
    if (env_var_sel == "uc_only") {
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
  if (is.null(catalog)) {
    catalogs <- dbGetQuery(con,  "show catalogs")
    if (nrow(catalogs) > 0) {
      df_catalogs <- data.frame(name = catalogs$catalog, type = "catalog")
    }
    comb <- rbind(df_tables, df_catalogs)
    out <- head(comb, limit)
  } else {
    if (is.null(schema)) {
      databases <- dbGetQuery(con,  glue("show databases in {catalog}"))
      df_databases <- data.frame(name = databases$databaseName, type = "schema")
      out <- head(df_databases, limit)
    } else {
      tables <- dbGetQuery(con,  glue("show tables in {catalog}.{schema}"))
      if (length(tables) > 0) {
        df_tables <- data.frame(
          name = tables$tableName,
          catalog = catalog,
          schema = schema,
          type = "table"
        )
      }

      out <- head(df_tables, limit)
    }
  }
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
  from <- NULL
  if(!is.null(catalog)) {
    from <- in_catalog(catalog, schema, table)
  }
  if(!is.null(schema) && is.null(from)) {
    from <- in_schema(schema, table)
  }
  if(is.null(from)) {
    from <- table
  }
  tbl(con, from)
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
    type = NULL,
    catalog_tbl = in_catalog("system", "information_schema", "catalogs"),
    schema_tbl = in_catalog("system", "information_schema", "schemata"),
    tables_tbl = in_catalog("system", "information_schema", "tables")) {
  limit <- as.numeric(
    Sys.getenv("SPARKLYR_CONNECTION_OBJECT_LIMIT", unset = 100)
  )

  if (is.null(catalog)) {
    all_catalogs <- tbl(src = con, catalog_tbl)

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

  if (is.null(schema) && !is.null(catalog)) {
    all_schema <- tbl(src = con, schema_tbl)

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

  if (!is.null(schema) && !is.null(catalog)) {
    all_tables <- tbl(src = con, tables_tbl)

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
  "table_name", "table_schema"
))
