skip_spark_min_version(3.5)

test_that("Pipeline fits and predicts", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()

  new_pipeline <- sc %>%
    ml_pipeline() %>%
    ft_max_abs_scaler(input_col = "features", output_col = "scaled_features") %>%
    ml_logistic_regression(features_col = "scaled_features", max_iter = 10)

  prepd <- ml_prepare_dataset(tbl_mtcars, am ~ .)

  expect_silent(fitted <- ml_fit(new_pipeline, prepd))

  expect_snapshot(class(fitted))

  pipeline_folder <- path(tempdir(), random_table_name("ml_"))
  expect_silent(ml_save(new_pipeline, pipeline_folder))
  expect_s3_class(ml_connect_load(sc, pipeline_folder), "ml_connect_pipeline")

  fitted_folder <- path(tempdir(), random_table_name("ml_"))
  expect_silent(ml_save(fitted, fitted_folder))
  loaded <- ml_connect_load(sc, fitted_folder)
  expect_s3_class(loaded, "ml_connect_pipeline_model")
  expect_snapshot(colnames(ml_transform(loaded, prepd)))
})
