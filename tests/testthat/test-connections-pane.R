test_that("Object retrieval function work", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()

  expect_s3_class(
    spark_ide_preview.pyspark_connection(sc, table = "mtcars", rowLimit = 10),
    "data.frame"
  )

  expect_s3_class(spark_ide_objects(sc), "data.frame")

  expect_snapshot(
    spark_ide_columns(sc, table = "mtcars")
  )

  expect_snapshot(
    spark_ide_preview(sc, table = "mtcars", rowLimit = 10)
  )

  expect_s3_class(
    catalog_python(sc, catalog = "spark_catalog"),
    "data.frame"
  )

  expect_s3_class(
    catalog_python(sc, catalog = "spark_catalog", schema = "default"),
    "data.frame"
  )

  expect_s3_class(
    rs_get_databases(sc, limit = 10, catalog = "spark_catalog"),
    "data.frame"
  )
})
