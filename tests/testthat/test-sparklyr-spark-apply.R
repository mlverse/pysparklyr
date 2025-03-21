test_that("spark_apply() works", {
  py_install("rpy2")
  tbl_mtcars <- use_test_table_mtcars()
  expect_s3_class(
    spark_apply(tbl_mtcars, nrow, group_by = "am", columns = "am double, x long"),
    "tbl_spark"
  )
  skip_spark_min_version(3.5)
  expect_s3_class(
    spark_apply(tbl_mtcars, function(x) x),
    "tbl_spark"
  )
  # expect_s3_class(
  #   spark_apply(tbl_mtcars, function(x) x, fetch_result_as_sdf = FALSE),
  #   "data.frame"
  # )
  expect_s3_class(
    spark_apply(tbl_mtcars, function(x) x, arrow_max_records_per_batch = 5000),
    "tbl_spark"
  )
  expect_s3_class(
    spark_apply(tbl_mtcars, ~.x),
    "tbl_spark"
  )
  expect_s3_class(
    spark_apply(dplyr::filter(tbl_mtcars, am == 0), ~.x),
    "tbl_spark"
  )
  expect_error(
    spark_apply(tbl_mtcars, function(x, y) y, context = 1)
  )
  expect_s3_class(
    spark_apply(tbl_mtcars, function(x, y) y, context = 1, group_by = "am"),
    "tbl_spark"
  )
})

test_that("Errors are output by specific params", {
  expect_error(spark_apply(tbl_mtcars, nrow, packages = "test"))
  expect_error(spark_apply(tbl_mtcars, nrow, context = ""))
  expect_error(spark_apply(tbl_mtcars, nrow, auto_deps = TRUE))
  expect_error(spark_apply(tbl_mtcars, nrow, partition_index_param = "test"))
})
