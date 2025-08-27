test_that("Random Forest Classifier works", {
  sc <- use_test_spark_connect()
  tbl_iris <- use_test_table_iris()
  expect_snapshot(class(ml_random_forest_classifier(ml_pipeline(sc))))
  expect_snapshot(class(ml_random_forest_classifier(sc)))
  x <- tbl_iris %>%
    ft_string_indexer("Species", "species_idx") %>%
    ml_random_forest_classifier(species_idx ~ Petal_Length + Petal_Width)
  expect_snapshot(class(x))
})
