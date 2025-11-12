skip_spark_min_version(4)

test_that("Binary evaluation works", {
  sc <- use_test_spark_connect()
  tbl_iris <- use_test_table_iris()
  expect_snapshot(class(ml_binary_classification_evaluator(sc)))
  tbl_mtcars <- use_test_table_mtcars()
  model <- tbl_mtcars |>
    ml_logistic_regression(am ~ .)
  preds <- ml_predict(model, tbl_mtcars)
  expect_snapshot(
    ml_binary_classification_evaluator(preds, label_col = "am")
  )
})

test_that("Regression evaluation works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ml_regression_evaluator(sc)))
  tbl_mtcars <- use_test_table_mtcars()
  model <- tbl_mtcars |>
    ml_linear_regression(wt ~ .)
  preds <- ml_predict(model, tbl_mtcars)
  expect_snapshot(
    ml_regression_evaluator(preds, label_col = "wt", metric_name = "r2")
  )
})

test_that("Multiclass evaluation works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ml_multiclass_classification_evaluator(sc)))
  tbl_iris <- use_test_table_iris() |>
    ft_string_indexer("Species", "species_idx")
  model <- tbl_iris |>
    ml_random_forest_classifier(
      species_idx ~ Sepal_Length + Sepal_Width + Petal_Length + Petal_Width
    )
  preds <- ml_predict(model, tbl_iris)
  expect_snapshot(
    ml_multiclass_classification_evaluator(preds, label_col = "species_idx")
  )
})

test_that("Clustering evaluation works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ml_clustering_evaluator(sc)))
  tbl_iris <- use_test_table_iris() |>
    ft_string_indexer("Species", "species_idx")
  model <- tbl_iris |>
    ml_kmeans(species_idx ~ Sepal_Length + Sepal_Width + Petal_Length + Petal_Width, seed = 1)
  preds <- ml_predict(model, tbl_iris)
  expect_snapshot(
    preds |>
      mutate(prediction = as.numeric(prediction)) |>
      compute() |>
      ml_regression_evaluator(label_col = "species_idx")
  )
})
