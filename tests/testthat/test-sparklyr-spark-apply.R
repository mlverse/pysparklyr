test_that("spark_apply() works", {
  tbl_mtcars <- use_test_table_mtcars()
  expect_s3_class(
    spark_apply(tbl_mtcars, nrow, group_by = "am"),
    "tbl_spark"
  )
  expect_s3_class(
    spark_apply(tbl_mtcars, function(x) x),
    "tbl_spark"
  )
  expect_s3_class(
    spark_apply(tbl_mtcars, function(x) x, fetch_result_as_sdf = FALSE),
    "data.frame"
  )
})
