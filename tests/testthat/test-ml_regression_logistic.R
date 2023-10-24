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

test_that("Logistic Regression works with Spark Connection", {
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



