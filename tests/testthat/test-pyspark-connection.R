test_that("Invoke works", {
  sc <- use_test_spark_connect()
  use_test_table_mtcars()
  expect_s3_class(
    invoke(sc, "sql", "select * from mtcars limit 5"),
    "spark_pyobj"
  )
})
