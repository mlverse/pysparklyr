skip_on_ci()
skip_spark_min_version("4")

test_that("Functions work", {
  reticulate::py_require("torch")
  tbl_mtcars <- use_test_table_mtcars()
  model <- use_test_lr_model()
  expect_length(
    suppressMessages(capture.output(print(model))),
    24
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
