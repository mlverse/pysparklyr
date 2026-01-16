use_test_pull <- function(x, table = FALSE) {
  x <- dplyr::pull(x)
  if (table) {
    x <- table(x)
  }
  if (inherits(x[[1]], "array")) {
    x <- as.double(map(x, as.vector))
  }
  if (inherits(x[[1]], "pyspark.ml.linalg.SparseVector")) {
    x <- data.frame(
      x = map_chr(x, function(x) paste(as.vector(x$values), collapse = ", "))
    )
  }
  if (inherits(x[[1]], "pyspark.ml.linalg.DenseVector")) {
    x <- data.frame(
      x = map_chr(x, function(x) paste(as.vector(x$array), collapse = ", "))
    )
  }
  x
}

use_test_iris_va <- function() {
  use_test_table_iris() |>
    ft_vector_assembler(
      input_cols = c("Sepal_Length", "Sepal_Width", "Petal_Length"),
      output_col = "vec_x"
    )
}

use_test_mtcars_va <- function() {
  use_test_table_mtcars() |>
    ft_vector_assembler(
      input_cols = c("mpg", "wt", "cyl"),
      output_col = "vec_x"
    )
}


# ------------------------------ Tune Grid -------------------------------------

use_tune_grid <- function() {
  if (is.null(.test_env$tune_grid)) {
    out <- list()
    set.seed(1010110)
    object <- parsnip::decision_tree(tree_depth = tune()) |>
      parsnip::set_mode("classification") |>
      parsnip::set_engine("rpart")
    preprocessor <- recipes::recipe(Species ~ ., data = iris) |>
      recipes::step_normalize(recipes::all_predictors()) |>
      recipes::step_pca(recipes::all_numeric_predictors(), num_comp = tune::tune())
    resamples <- rsample::bootstraps(iris, 5)
    wf_grid <- dials::grid_regular(dials::num_comp(c(1L, 15L)), dials::tree_depth())
    cntrl <- tune::control_grid(verbose = TRUE, save_pred = TRUE)
    results <- tune::tune_grid(
      object = object,
      preprocessor = preprocessor,
      resamples = resamples,
      grid = wf_grid
    )
    out$object <- object
    out$preprocessor <- preprocessor
    out$resamples <- resamples
    out$grid <- wf_grid
    out$control <- cntrl
    out$results <- results
    .test_env$tune_grid <- out
  }
  .test_env$tune_grid
}
