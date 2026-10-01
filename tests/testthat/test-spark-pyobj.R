test_that("Print method works", {
  sc <- use_test_spark_connect()
  use_test_table_mtcars()
  expect_message(print(invoke(sc, "sql", "select * from mtcars limit 5")))
})

test_that("sdf_read_column() works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  sdf <- spark_dataframe(tbl_mtcars)
  expect_s3_class(sdf, "spark_pyobj")
  expect_equal(
    sdf_read_column(sdf, "mpg"),
    mtcars$mpg
  )
})
