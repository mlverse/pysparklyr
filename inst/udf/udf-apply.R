function(df = mtcars) {
  library(arrow)
  fn <- function(...) 1
  fn_run <- fn(df)
  gp_field <- 'am'
  col_names <- c('am', 'x')
  gp <- df[1, gp_field]
  if (is.vector(fn_run)) {
    ret <- data.frame(x = fn_run)
  } else {
    ret <- as.data.frame(fn_run)
  }
  ret[gp_field] <- gp
  cols <- colnames(ret)
  gp_cols <- cols == gp_field
  new_cols <- c(cols[gp_cols], cols[!gp_cols])
  ret <- ret[, new_cols]
  if (!is.null(col_names)) {
    colnames(ret) <- col_names
  }
  ret
}
