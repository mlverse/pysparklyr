test_that("Print method works", {
  use_test_table_mtcars()
  expect_message(print(invoke(sc, "sql", "select * from mtcars limit 5")))
})
