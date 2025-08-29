use_test_pull <- function(x, table = FALSE) {
  x <- dplyr::pull(x)
  if(table) {
    x <- table(x)
  }
  if(inherits(x[[1]], "array")) {
    x <- as.double(map(x, as.vector))
  }
  if(inherits(x[[1]], "pyspark.ml.linalg.SparseVector")) {
    x <- map(x, function(x) x$values)
  }
  if(inherits(x[[1]], "pyspark.ml.linalg.DenseVector")) {
    x <- data.frame(
      x = map_chr(x, function(x) paste(as.vector(x$array), collapse = ", "))
      )
  }
  x
}

use_test_iris_va <- function() {
  use_test_table_iris() %>%
    ft_vector_assembler(
      input_cols = c("Sepal_Length", "Sepal_Width", "Petal_Length"),
      output_col = "vec_x"
    )
}

use_test_mtcars_va <- function() {
  use_test_table_mtcars() %>%
    ft_vector_assembler(
      input_cols = c("mpg", "wt", "cyl"),
      output_col = "vec_x"
    )
}
