test_that("Pipeline fits and predicts", {
  sc <- test_spark_connect()
  tbl_mtcars <- test_table_mtcars()

  new_pipeline <- sc %>%
    ml_pipeline() %>%
    ft_max_abs_scaler(input_col = "features", output_col = "scaled_features") %>%
    ml_logistic_regression(features_col = "scaled_features", max_iter = 10)

  prepd <- ml_prepare_dataset(tbl_mtcars, am ~ .)

  expect_silent(fitted <- ml_fit(new_pipeline, prepd))

  expect_snapshot(class(fitted))

  expect_snapshot(
    fitted %>%
      ml_transform(prepd) %>%
      colnames()
  )
})
