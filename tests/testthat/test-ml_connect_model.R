test_that("Functions work", {
  sc <- test_spark_connect()
  tbl_mtcars <- test_table_mtcars()

  model <- ml_logistic_regression(tbl_mtcars, am ~ ., max_iter = 10)

  expect_snapshot(model)

  expect_s3_class(spark_jobj(model), "spark_pyobj")

  expect_s3_class(ml_predict(model, tbl_mtcars), "tbl_pyspark")

  expect_snapshot(
    colnames(transform_impl(model, tbl_mtcars, prep = TRUE))
  )

  expect_snapshot(
    colnames(transform_impl(model, tbl_mtcars, prep = TRUE, remove = TRUE))
  )
})
