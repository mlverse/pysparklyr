skip_on_ci()

test_that("Object retrieval function work", {
  sc <- test_spark_connect()
  tbl_mtcars <- copy_to(sc, mtcars, overwrite = TRUE)
  expect_type(spark_ide_objects(sc), "list")

  expect_snapshot(
    spark_ide_columns(sc, table = "mtcars")
  )

  expect_snapshot(
    spark_ide_preview(sc, table = "mtcars", rowLimit = 10)
  )

})