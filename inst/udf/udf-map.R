function(df = mtcars) {
  library(arrow);
  fn <- function(...) 1;
  fn_run <- fn(df);
  if(is.vector(fn_run)) {
    ret <- data.frame(x = fn_run);
  } else {
    ret <- as.data.frame(fn_run);
  };
  ret
}
