skip_on_ci()
skip_spark_min_version(4.0)

test_that("Linear regression works", {
  sc <- use_test_spark_connect()
  tbl_iris <- use_test_table_iris()
  expect_snapshot(class(ml_linear_regression(ml_pipeline(sc))))
  expect_snapshot(class(ml_linear_regression(sc)))
  model <- use_test_table_mtcars() %>%
    ml_linear_regression(wt ~ .)
  expect_snapshot(class(model))
  expect_snapshot(model)
  fitted <- model %>%
    ml_predict(use_test_table_mtcars()) %>%
    pull()
  expect_snapshot(table(fitted))
})

test_that("Logistic regression works", {
  sc <- use_test_spark_connect()
  tbl_iris <- use_test_table_iris()
  expect_snapshot(class(ml_logistic_regression(ml_pipeline(sc))))
  expect_snapshot(class(ml_logistic_regression(sc)))
  model <- use_test_table_mtcars() %>%
    ml_logistic_regression(am ~ .)
  expect_snapshot(model)
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
  expect_snapshot(model)
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
  expect_snapshot(model)
  expect_snapshot(class(model))
  x <- tbl_mtcars %>%
    ml_predict(model, .) %>%
    collect()
  expect_true("prediction" %in% names(x))
})

test_that("Decision Tree Classifier works", {
  sc <- use_test_spark_connect()
  tbl_iris <- use_test_table_iris()
  expect_snapshot(class(ml_decision_tree_classifier(ml_pipeline(sc))))
  expect_snapshot(class(ml_decision_tree_classifier(sc)))
  model <- tbl_iris %>%
    ft_string_indexer("Species", "species_idx") %>%
    ml_decision_tree_classifier(species_idx ~ Petal_Length + Petal_Width, seed = 100)
  expect_snapshot(model)
  expect_snapshot(class(model))
  x <- tbl_iris %>%
    ft_string_indexer("Species", "species_idx") %>%
    ml_predict(model, .) %>%
    collect()
  expect_snapshot(table(x$prediction))
})

test_that("Decision Tree Regressor works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  expect_snapshot(class(ml_decision_tree_regressor(ml_pipeline(sc))))
  expect_snapshot(class(ml_decision_tree_regressor(sc)))
  model <- tbl_mtcars %>%
    ml_decision_tree_regressor(mpg ~ ., seed = 100)
  expect_snapshot(model)
  expect_snapshot(class(model))
  x <- tbl_mtcars %>%
    ml_predict(model, .) %>%
    collect()
  expect_true("prediction" %in% names(x))
})

test_that("Kmeans works", {
  sc <- use_test_spark_connect()
  tbl_iris <- use_test_table_iris()
  expect_snapshot(class(ml_kmeans(sc)))
  expect_snapshot(class(ml_kmeans(ml_pipeline(sc))))
  model <- tbl_iris %>%
    ml_kmeans(Species ~ .)
  preds <- model %>%
    ml_predict(tbl_iris) %>%
    dplyr::pull() %>%
    table()
  expect_snapshot(preds)
})
