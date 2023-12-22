test_that("Write table works", {
  tbl_mtcars <- use_test_table_mtcars()
  expect_silent(
    spark_write_table(tbl_mtcars, "new_mtcars")
  )
  dir_delete(test_path("spark-warehouse"))
})

test_that("CSV works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  file_name <- tempfile()
  expect_silent(spark_write_csv(tbl_mtcars, file_name))
  expect_snapshot(
    spark_read_csv(sc, "csv_1", file_name, overwrite = TRUE)
  )
})

test_that("Parquet works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  file_name <- tempfile()
  expect_silent(spark_write_parquet(tbl_mtcars, file_name))
  expect_snapshot(
    spark_read_parquet(sc, "csv_1", file_name, overwrite = TRUE)
  )
})

test_that("ORC works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  file_name <- tempfile()
  expect_silent(spark_write_orc(tbl_mtcars, file_name))
  expect_snapshot(
    spark_read_orc(sc, "csv_1", file_name, overwrite = TRUE)
  )
})

test_that("JSON works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  file_name <- tempfile()
  expect_silent(spark_write_json(tbl_mtcars, file_name))
  expect_snapshot(
    spark_read_json(sc, "csv_1", file_name, overwrite = TRUE)
  )
})
