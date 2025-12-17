vec_list_rowwise <- function(x) {
  vctrs::vec_split(x, by = 1:nrow(x))$val
}

update_parallel_over <- function(control, resamples, grid) {
  num_candidates <- nrow(grid)

  if (is.null(control$parallel_over) | num_candidates == 0) {
    control$parallel_over <- "resamples"
  }
  if (length(resamples$splits) == 1 & num_candidates > 0) {
    control$parallel_over <- "everything"
  }
  control
}
