test_that("copy_to() works", {
  sc <- test_spark_connect()
  expect_silent(
    tbl_mtcars <- copy_to(sc, mtcars, overwrite = TRUE)
  )
  expect_snapshot(print(tbl_mtcars))

  expect_snapshot(print(head(tbl_mtcars)))

})
