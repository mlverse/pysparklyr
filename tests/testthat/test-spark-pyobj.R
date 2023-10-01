test_that("Print method works", {
  sc <- test_spark_connect()
  test_table_mtcars()
  expect_snapshot(
    print(invoke(sc, "sql", "select * from mtcars limit 5")),
  )
})

