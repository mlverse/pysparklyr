skip_spark_min_version(4.0)

test_that("Logistic regression works", {
  sc <- use_test_spark_connect()
  tbl_iris <- use_test_table_iris()
  expect_snapshot(class(ml_logistic_regression(ml_pipeline(sc))))
  expect_snapshot(class(ml_logistic_regression(sc)))
  model <- use_test_table_mtcars() |>
    ml_logistic_regression(am ~ .)
  expect_snapshot(class(model))
  fitted <- model |>
    ml_predict(use_test_table_mtcars()) |>
    pull()
  expect_snapshot(table(fitted))
})

test_that("Linear regression works", {
  sc <- use_test_spark_connect()
  tbl_iris <- use_test_table_iris()
  expect_snapshot(class(ml_linear_regression(ml_pipeline(sc))))
  expect_snapshot(class(ml_linear_regression(sc)))
  model <- use_test_table_mtcars() |>
    ml_linear_regression(wt ~ .)
  expect_snapshot(class(model))
  expect_snapshot(model)
  fitted <- model |>
    ml_predict(use_test_table_mtcars()) |>
    use_test_pull() |>
    round(2) |>
    sort()
  expect_snapshot(fitted)
})

test_that("Random Forest Classifier works", {
  sc <- use_test_spark_connect()
  tbl_iris <- use_test_table_iris()
  expect_snapshot(class(ml_random_forest_classifier(ml_pipeline(sc))))
  expect_snapshot(class(ml_random_forest_classifier(sc)))
  model <- tbl_iris |>
    ft_string_indexer("Species", "species_idx") |>
    ml_random_forest_classifier(species_idx ~ Petal_Length + Petal_Width)
  expect_snapshot(class(model))
  x <- tbl_iris |>
    ft_string_indexer("Species", "species_idx") |>
    ml_predict(model, dataset = _) |>
    use_test_pull() |>
    table()
  expect_length(x, 3)
})

test_that("Random Forest Regressor works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  expect_snapshot(class(ml_random_forest_regressor(ml_pipeline(sc))))
  expect_snapshot(class(ml_random_forest_regressor(sc)))
  model <- tbl_mtcars |>
    ml_random_forest_regressor(mpg ~ ., seed = 100)
  expect_snapshot(model)
  expect_snapshot(class(model))
  x <- tbl_mtcars |>
    ml_predict(model, dataset = _) |>
    collect()
  expect_true("prediction" %in% names(x))
})

test_that("Decision Tree Classifier works", {
  sc <- use_test_spark_connect()
  tbl_iris <- use_test_table_iris()
  expect_snapshot(class(ml_decision_tree_classifier(ml_pipeline(sc))))
  expect_snapshot(class(ml_decision_tree_classifier(sc)))
  model <- tbl_iris |>
    ft_string_indexer("Species", "species_idx") |>
    ml_decision_tree_classifier(species_idx ~ Petal_Length + Petal_Width, seed = 100)
  expect_snapshot(model)
  expect_snapshot(class(model))
  x <- tbl_iris |>
    ft_string_indexer("Species", "species_idx") |>
    ml_predict(model, dataset = _) |>
    collect()
  expect_snapshot(table(x$prediction))
})

test_that("Decision Tree Regressor works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  expect_snapshot(class(ml_decision_tree_regressor(ml_pipeline(sc))))
  expect_snapshot(class(ml_decision_tree_regressor(sc)))
  model <- tbl_mtcars |>
    ml_decision_tree_regressor(mpg ~ ., seed = 100)
  expect_snapshot(model)
  expect_snapshot(class(model))
  x <- tbl_mtcars |>
    ml_predict(model, dataset = _) |>
    collect()
  expect_true("prediction" %in% names(x))
})

test_that("Kmeans works", {
  sc <- use_test_spark_connect()
  tbl_iris <- use_test_table_iris()
  expect_snapshot(class(ml_kmeans(sc)))
  expect_snapshot(class(ml_kmeans(ml_pipeline(sc))))
  model <- tbl_iris |>
    ml_kmeans(Species ~ .)
  preds <- model |>
    ml_predict(tbl_iris) |>
    use_test_pull() |>
    table()
  expect_length(preds, 2)
})

test_that("Bisecting Kmeans works", {
  sc <- use_test_spark_connect()
  tbl_iris <- use_test_table_iris()
  expect_snapshot(class(ml_bisecting_kmeans(sc)))
  expect_snapshot(class(ml_bisecting_kmeans(ml_pipeline(sc))))
  model <- tbl_iris |>
    ml_bisecting_kmeans(Species ~ .)
  preds <- model |>
    ml_predict(tbl_iris) |>
    dplyr::pull() |>
    table() |>
    sort() |>
    as.vector()
  expect_snapshot(preds)
})

test_that("AFT Survival works", {
  sc <- use_test_spark_connect()
  tbl_ovarian <- use_test_table_ovarian()
  expect_snapshot(class(ml_aft_survival_regression(ml_pipeline(sc))))
  expect_snapshot(class(ml_aft_survival_regression(sc)))
  model <- tbl_ovarian |>
    ml_aft_survival_regression(futime ~ ecog_ps + rx + age + resid_ds, censor_col = "fustat")
  expect_snapshot(model)
  expect_snapshot(class(model))
  x <- tbl_ovarian |>
    ml_predict(model, dataset = _) |>
    collect()
  expect_true("prediction" %in% names(x))
})

test_that("GBT classifiers works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  expect_snapshot(class(ml_gbt_classifier(ml_pipeline(sc))))
  expect_snapshot(class(ml_gbt_classifier(sc)))
  model <- tbl_mtcars |>
    ml_gbt_classifier(am ~ .)
  expect_snapshot(class(model))
  x <- tbl_mtcars |>
    ml_predict(model, dataset = _) |>
    use_test_pull()
  expect_snapshot(table(x))
})

test_that("GBT Regressor works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  expect_snapshot(class(ml_gbt_regressor(ml_pipeline(sc))))
  expect_snapshot(class(ml_gbt_regressor(sc)))
  model <- tbl_mtcars |>
    ml_gbt_regressor(mpg ~ ., seed = 100)
  expect_snapshot(model)
  expect_snapshot(class(model))
  x <- tbl_mtcars |>
    ml_predict(model, dataset = _) |>
    collect()
  expect_true("prediction" %in% names(x))
})

test_that("Isotonic regression works", {
  sc <- use_test_spark_connect()
  tbl_iris <- use_test_table_iris()
  expect_snapshot(class(ml_isotonic_regression(ml_pipeline(sc))))
  expect_snapshot(class(ml_isotonic_regression(sc)))
  model <- tbl_iris |>
    ml_isotonic_regression(Petal_Length ~ Petal_Width)
  expect_snapshot(model)
  expect_snapshot(class(model))
  x <- tbl_iris |>
    ml_predict(model, dataset =  _) |>
    collect()
  expect_true("prediction" %in% names(x))
})

test_that("Generalized linear regression works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  expect_snapshot(class(ml_generalized_linear_regression(ml_pipeline(sc))))
  expect_snapshot(class(ml_generalized_linear_regression(sc)))
  model <- tbl_mtcars |>
    ml_generalized_linear_regression(mpg ~ .)
  expect_snapshot(class(model))
  x <- tbl_mtcars |>
    ml_predict(model, dataset = _) |>
    collect()
  expect_true("prediction" %in% names(x))
})
