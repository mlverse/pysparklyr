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
