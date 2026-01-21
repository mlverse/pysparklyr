function(df = mtcars) {
  library(arrow)
  fn <- function(...) 1
  col_names <- c('am', 'x')
  fn_run <- fn(df)
  if (is.vector(fn_run)) {
    ret <- data.frame(x = fn_run)
  } else {
    ret <- as.data.frame(fn_run)
  }
  if (!is.null(col_names)) {
    colnames(ret) <- col_names
  }
  ret
}
