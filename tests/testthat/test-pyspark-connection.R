test_that("Invoke works", {
  sc <- test_spark_connect()
  test_table_mtcars()
  expect_s3_class(
    invoke(sc, "sql", "select * from mtcars limit 5"),
    "spark_pyobj"
  )
})
