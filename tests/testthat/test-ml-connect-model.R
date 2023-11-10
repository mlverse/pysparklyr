skip_spark_min_version(3.5)

test_that("Functions work", {
  tbl_mtcars <- test_table_mtcars()
  model <-test_lr_model()
  expect_equal(
    print(model),
    NULL
  )

  expect_s3_class(spark_jobj(model), "spark_pyobj")

  expect_s3_class(ml_predict(model, tbl_mtcars), "tbl_pyspark")

  expect_snapshot(
    colnames(transform_impl(model, tbl_mtcars, prep = TRUE))
  )

  expect_snapshot(
    colnames(transform_impl(model, tbl_mtcars, prep = TRUE, remove = TRUE))
  )
})
