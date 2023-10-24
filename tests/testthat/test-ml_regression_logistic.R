skip_spark_min_version(3.5)

test_that("Logistic Regression works with Spark Connection", {
  sc <- test_spark_connect()
  expect_s3_class(
    ml_logistic_regression(sc) ,
    "ml_connect_estimator"
  )
})




