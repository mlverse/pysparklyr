test_that("Object retrieval function work", {
  sc <- test_spark_connect()
  tbl_mtcars <- test_table_mtcars()
  expect_s3_class(spark_ide_objects(sc), "data.frame")

  expect_snapshot(
    spark_ide_columns(sc, table = "mtcars")
  )

  expect_snapshot(
    spark_ide_preview(sc, table = "mtcars", rowLimit = 10)
  )

})

test_that("DB sql", {
  sc <- test_spark_connect()
  temp_items <- data.frame(
    catalog_name = "catalog",
    schema_name = "schema",
    table_catalog = "catalog",
    table_schema = "schema",
    table_name = "table",
    comment = "this is a comment"
  )
  tbl_items <- copy_to(sc, temp_items, overwrite = TRUE)

  expect_s3_class(catalog_sql(sc, catalog_tbl = "temp_items"), "data.frame")
  expect_s3_class(
    catalog_sql(sc, catalog = "catalog", schema_tbl = "temp_items")
    , "data.frame"
    )
  expect_s3_class(
    catalog_sql(sc, catalog = "catalog", schema = "schema", tables_tbl = "temp_items"),
    "data.frame"
    )

  dbRemoveTable(sc, "temp_items")
})
