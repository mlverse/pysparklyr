skip_on_ci()

test_that("CSV works", {
  sc <- test_spark_connect()
  tbl_mtcars <- test_table_mtcars()
  file_name <- tempfile()
  expect_silent(spark_write_csv(tbl_mtcars, file_name))
  expect_snapshot(
    spark_read_csv(sc, "csv_1", file_name, overwrite = TRUE)
  )
})

test_that("Parquet works", {
  sc <- test_spark_connect()
  tbl_mtcars <- test_table_mtcars()
  file_name <- tempfile()
  expect_silent(spark_write_parquet(tbl_mtcars, file_name))
  expect_snapshot(
    spark_read_parquet(sc, "csv_1", file_name, overwrite = TRUE)
  )
})

test_that("ORC works", {
  sc <- test_spark_connect()
  tbl_mtcars <- test_table_mtcars()
  file_name <- tempfile()
  expect_silent(spark_write_orc(tbl_mtcars, file_name))
  expect_snapshot(
    spark_read_orc(sc, "csv_1", file_name, overwrite = TRUE)
  )
})

test_that("JSON works", {
  sc <- test_spark_connect()
  tbl_mtcars <- test_table_mtcars()
  file_name <- tempfile()
  expect_silent(spark_write_json(tbl_mtcars, file_name))
  expect_snapshot(
    spark_read_json(sc, "csv_1", file_name, overwrite = TRUE)
  )
})
