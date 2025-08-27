skip_on_ci()
skip_spark_min_version(3.5)

test_that("Logistic Regression works with Spark Connection", {
  use_test_install_ml()
  sc <- use_test_spark_connect()
  expect_s3_class(
    ml_logistic_regression(sc),
    "ml_connect_estimator"
  )
  expect_snapshot(
    class(ml_logistic_regression(sc, max_iter = 10))
  )
})

test_that("Logistic Regression works with `tbl_spark`", {
  tbl_mtcars <- use_test_table_mtcars()
  expect_silent(model <- use_test_lr_model())
  print_model <- suppressMessages(capture.output(print(model)))
  expect_length(print_model, 23)
  expect_snapshot(model$features)
  expect_snapshot(model$label)

  expect_snapshot(
    model %>%
      ml_predict(tbl_mtcars) %>%
      colnames()
  )
})

test_that("Logistic Regression works with Pipeline", {
  sc <- use_test_spark_connect()

  expect_silent(
    out <- sc %>%
      ml_pipeline() %>%
      ml_logistic_regression()
  )
  cap_out <- capture.output(out)
  expect_snapshot(cap_out[c(1, 3:4, 6:18)])
})
