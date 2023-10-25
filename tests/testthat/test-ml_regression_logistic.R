skip_spark_min_version(3.5)

test_that("Logistic Regression works with Spark Connection", {
  sc <- test_spark_connect()
  expect_s3_class(
    ml_logistic_regression(sc),
    "ml_connect_estimator"
  )
  expect_snapshot(
    class(ml_logistic_regression(sc))
  )
})

test_that("Logistic Regression works with `tbl_spark`", {
  sc <- test_spark_connect()
  tbl_mtcars <- test_table_mtcars()
  expect_silent(model <- ml_logistic_regression(tbl_mtcars, am ~ .))
  expect_snapshot(model$features)
  expect_snapshot(model$label)

  expect_snapshot(
    model %>%
      ml_predict(tbl_mtcars) %>%
      colnames()
  )
})

test_that("Logistic Regression works with Pipeline", {
  sc <- test_spark_connect()

  expect_silent(
    out <- sc %>%
      ml_pipeline() %>%
      ml_logistic_regression()
  )
  cap_out <- capture.output(out)
  expect_snapshot(cap_out[c(1, 3:4, 6:18)])
})


test_that("Print method works", {
  sc <- test_spark_connect()
  expect_snapshot(
    ml_logistic_regression(sc)
  )

})
