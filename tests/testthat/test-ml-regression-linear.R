skip_on_ci()
skip_spark_min_version(4.0)

test_that("Linear Regression works with Spark Connection", {
  use_test_install_ml()
  sc <- use_test_spark_connect()
  expect_s3_class(
    ml_linear_regression(sc),
    "ml_connect_estimator"
  )
  expect_snapshot(
    class(ml_linear_regression(sc, max_iter = 10))
  )
})

test_that("Linear Regression works with `tbl_spark`", {
  tbl_mtcars <- use_test_table_mtcars()
  expect_silent(model <- ml_linear_regression(tbl_mtcars, mpg ~ .))
  print_model <- suppressMessages(capture.output(model))
  expect_length(print_model, 19)
  expect_snapshot(model$features)
  expect_snapshot(model$label)
  expect_snapshot(
    model %>%
      ml_predict(tbl_mtcars) %>%
      colnames()
  )
})

test_that("Linear Regression works with Pipeline", {
  sc <- use_test_spark_connect()
  expect_silent(
    out <- sc %>%
      ml_pipeline() %>%
      ml_linear_regression()
  )
  cap_out <- capture.output(out)
  expect_snapshot(cap_out[c(1, 3:4, 6:18)])
})
