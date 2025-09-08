skip_spark_min_version(4)

test_that("Cross validator works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()

  pipeline <- sc %>%
    ml_pipeline() %>%
    ft_binarizer("mpg", "mpg2", 20) %>%
    ft_r_formula(mpg2 ~ .) %>%
    ml_logistic_regression()

  grid <- list(
    logistic_regression = list(
      reg_param = seq(0, 1, length = 3)
    )
  )

  cv <- ml_cross_validator(
    x = sc,
    estimator = pipeline,
    estimator_param_maps = grid,
    evaluator = ml_binary_classification_evaluator(sc),
    seed = 100
  )

  expect_snapshot(class(cv))

  tuning_model <- ml_fit(cv, tbl_mtcars)
  expect_snapshot(class(tuning_model))

  metrics <- ml_validation_metrics(tuning_model)

  expect_snapshot(metrics)

  grid2 <- list(
    linear_regression = list(
      reg_param = seq(0, 1, length = 3)
    )
  )

  expect_error(
    cv <- ml_cross_validator(
      x = sc,
      estimator = pipeline,
      estimator_param_maps = grid2,
      evaluator = ml_binary_classification_evaluator(sc),
      seed = 100
    )
  )
})
