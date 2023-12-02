test_that("Print method works", {
  sc <- use_test_spark_connect()
  use_test_table_mtcars()
  expect_message(print(invoke(sc, "sql", "select * from mtcars limit 5")))
})
