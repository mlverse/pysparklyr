use_test_pull <- function(x, table = FALSE) {
  x <- dplyr::pull(x)
  if (table) {
    x <- table(x)
  }

  # Handle Spark ML vectors that come through as structured data frames
  # (Spark 4.1+ with Pandas 3.0+ converts ML vectors to data frames with type, size, indices, values columns)
  if (is.data.frame(x) && all(c("type", "size", "indices", "values") %in% names(x))) {
    # Extract the values column which contains the actual vector data
    x <- data.frame(
      x = map_chr(x$values, function(vec) {
        if (is.null(vec) || length(vec) == 0) {
          ""
        } else {
          paste(as.vector(vec), collapse = ", ")
        }
      })
    )
    return(x)
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
  # Handle vectors that have been converted to numeric during pandas conversion
  # (Spark 4.1+ with Pandas 3.0+ converts ML vectors to numeric vectors)
  if (is.list(x) && length(x) > 0 && is.numeric(x[[1]]) && !is.data.frame(x)) {
    x <- data.frame(
      x = map_chr(x, function(vec) paste(as.vector(vec), collapse = ", "))
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
      recipes::step_pca(
        recipes::all_numeric_predictors(),
        num_comp = tune::tune()
      )
    resamples <- rsample::bootstraps(iris, 5)
    wf_grid <- dials::grid_regular(
      dials::num_comp(c(1L, 15L)),
      dials::tree_depth()
    )
    cntrl <- tune::control_grid(verbose = TRUE, save_pred = TRUE)
    results <- tune::tune_grid(
      object = object,
      preprocessor = preprocessor,
      resamples = resamples,
      grid = wf_grid
    )
    post <- tailor::tailor() |>
      tailor::adjust_probability_calibration()
    out$object <- object
    out$preprocessor <- preprocessor
    out$resamples <- resamples
    out$grid <- wf_grid
    out$control <- cntrl
    out$post <- post
    out$results <- results
    .test_env$tune_grid <- out
  }
  .test_env$tune_grid
}

expect_equal_preds <- function(object, expected) {
  act <- quasi_label(enquo(object))
  act2 <- quasi_label(enquo(expected))
  res <- compare_pred_class(object, expected)
  res_n <- nrow(res)
  if (res_n > 0) {
    fail(
      glue::glue(
        "{act$lab} predictions do not match {act2$lab}. There were {res_n} differences."
      )
    )
  } else {
    pass()
  }
  invisible(act$val)
}

compare_pred_class <- function(x, y) {
  res <- NULL
  pred_size <- length(x$.predictions)
  for (i in seq_len(pred_size)) {
    x_i <- x$.predictions[[i]]
    y_i <- y$.predictions[[i]]
    x_preds <- dplyr::select(x_i, .config, .row, x_class = .pred_class)
    y_preds <- dplyr::select(y_i, .config, .row, y_class = .pred_class)
    res <- dplyr::left_join(x_preds, y_preds, by = c(".config", ".row")) |>
      dplyr::filter(x_class != y_class) |>
      dplyr::mutate(split = i) |>
      dplyr::bind_rows(res)
  }
  res
}
