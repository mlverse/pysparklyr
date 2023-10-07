ml_formula <- function(f, data) {
  col_data <- colnames(data)

  temp_tbl <- rep(1, times = length(col_data)) %>%
    purrr::set_names(col_data) %>%
    as.list() %>%
    as.data.frame()

  f_terms <- terms(f, data = temp_tbl)

  f_factors <- attr(f_terms, "factors")

  feat_names <- colnames(f_factors)
  row_f <- rownames(f_factors)

  for(i in feat_names) {
    in_data <- i %in% col_data
    if(!in_data) {
      cli_abort(c(
        "Formula resulted in an invalid parameter set\n",
        "- Only '+' is supported."
      ), call = NULL)
    }
  }

  label <- NULL
  for(i in row_f) {
    if(!(i %in% feat_names)) {
      label <- c(label, i)
    }
  }
  list(
    label = label,
    features = feat_names
  )
}
