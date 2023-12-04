skip_spark_min_version(3.5)

test_that("All ML calls return same error", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  skip_ml_not_missing()
  error_msg <- "Required Python libraries to run ML functions are missing"
  expect_error(ml_logistic_regression(sc, am ~.), error_msg)
  expect_error(ml_logistic_regression(tbl_mtcars, am ~.), error_msg)
  expect_error(ml_pipeline(sc), error_msg)
  expect_error(ft_max_abs_scaler(sc), error_msg)
  expect_error(ft_max_abs_scaler(tbl_mtcars), error_msg)
})
