skip_on_ci()
skip_spark_min_version(4.0)

test_that("Linear Regression works with Spark Connection", {
  use_test_install_ml()
  sc <- use_test_spark_connect()
  expect_s3_class(
    ml_linear_regression(sc),
    "ml_connect_estimator"
  )
  expect_snapshot(
    class(ml_linear_regression(sc, max_iter = 10))
  )
})

test_that("Linear Regression works with `tbl_spark`", {
  tbl_mtcars <- use_test_table_mtcars()
  expect_silent(model <- ml_linear_regression(tbl_mtcars, mpg ~ .))
  print_model <- suppressMessages(capture.output(model))
  expect_length(print_model, 19)
  expect_snapshot(model$features)
  expect_snapshot(model$label)
  expect_snapshot(
    model %>%
      ml_predict(tbl_mtcars) %>%
      colnames()
  )
})

test_that("Linear Regression works with Pipeline", {
  sc <- use_test_spark_connect()
  expect_silent(
    out <- sc %>%
      ml_pipeline() %>%
      ml_linear_regression()
  )
  cap_out <- capture.output(out)
  expect_snapshot(cap_out[c(1, 3:4, 6:18)])
})

test_that("Logistic regression works", {
  sc <- use_test_spark_connect()
  tbl_iris <- use_test_table_iris()
  expect_snapshot(class(ml_logistic_regression(ml_pipeline(sc))))
  expect_snapshot(class(ml_logistic_regression(sc)))
  model <- use_test_table_mtcars() %>%
    ml_logistic_regression(am ~ .)
  expect_snapshot(class(model))
  fitted <- model %>%
    ml_predict(use_test_table_mtcars()) %>%
    pull()
  expect_snapshot(table(fitted))
})

test_that("Random Forest Classifier works", {
  sc <- use_test_spark_connect()
  tbl_iris <- use_test_table_iris()
  expect_snapshot(class(ml_random_forest_classifier(ml_pipeline(sc))))
  expect_snapshot(class(ml_random_forest_classifier(sc)))
  model <- tbl_iris %>%
    ft_string_indexer("Species", "species_idx") %>%
    ml_random_forest_classifier(species_idx ~ Petal_Length + Petal_Width, seed = 100)
  expect_snapshot(class(model))
  x <- tbl_iris %>%
    ft_string_indexer("Species", "species_idx") %>%
    ml_predict(model, .) %>%
    collect()
  expect_snapshot(table(x$prediction))
})

test_that("Random Forest Regressor works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  expect_snapshot(class(ml_random_forest_regressor(ml_pipeline(sc))))
  expect_snapshot(class(ml_random_forest_regressor(sc)))
  model <- tbl_mtcars %>%
    ml_random_forest_regressor(mpg ~ ., seed = 100)
  expect_snapshot(class(model))
  x <- tbl_mtcars %>%
    ml_predict(model, .) %>%
    collect()
  expect_true("prediction" %in% names(x))
})
