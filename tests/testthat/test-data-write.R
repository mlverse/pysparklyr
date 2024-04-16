test_that("Write text works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  file_name <- tempfile()
  text_tbl <- tbl_mtcars %>%
    mutate(x = as.character(mpg)) %>%
    select(x)
  expect_silent(spark_write_text(text_tbl, file_name, overwrite = ))
  expect_s3_class(spark_read_text(sc, file_name), "tbl_pyspark")
})

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
    spark_read_csv(
      sc = sc,
      name = "csv_1",
      path = file_name,
      overwrite = TRUE,
      repartition = 2
    )
  )
  expect_snapshot(
    spark_read_csv(
      sc = sc,
      name = "csv_2",
      path = file_name,
      overwrite = TRUE,
      columns = paste0(names(mtcars), "t")
    )
  )
  expect_snapshot(
    spark_read_csv(
      sc = sc,
      name = "csv_3",
      path = file_name,
      overwrite = TRUE,
      memory = TRUE
    )
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

test_that("Other tests", {
  expect_equal(
    substr(gen_sdf_name("12-3-4"), 1, 5),
    "1234_"
  )
})
