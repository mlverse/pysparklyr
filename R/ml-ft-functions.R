# ------------------------------- Bucketizer -----------------------------------
ft_bucketizer_impl <- function(x, input_col = NULL, output_col = NULL,
                               splits = NULL, input_cols = NULL,
                               output_cols = NULL, splits_array = NULL,
                               handle_invalid = "error", uid = NULL, ...) {
  ml_process_fn(
    args = c(as.list(environment()), list(...)),
    fn = "Bucketizer",
    has_fit = FALSE
  )
}
#' @export
ft_bucketizer.ml_connect_pipeline <- ft_bucketizer_impl
#' @export
ft_bucketizer.pyspark_connection <- ft_bucketizer_impl
#' @export
ft_bucketizer.tbl_pyspark <- ft_bucketizer_impl

# ----------------------------- Binarizer --------------------------------------
ft_binarizer_impl <- function(x, input_col, output_col,
                              threshold = 0, uid = NULL, ...) {
  ml_process_fn(
    args = c(as.list(environment()), list(...)),
    fn = "Binarizer",
    has_fit = FALSE
  )
}
#' @export
ft_binarizer.ml_connect_pipeline <- ft_binarizer_impl
#' @export
ft_binarizer.pyspark_connection <- ft_binarizer_impl
#' @export
ft_binarizer.tbl_pyspark <- ft_binarizer_impl

# ----------------------------- RFormula ---------------------------------------

ft_r_formula_impl <- function(x, formula = NULL, features_col = "features",
                              label_col = "label", force_index_label = FALSE,
                              uid = NULL, ...) {
  ml_process_fn(
    args = c(as.list(environment()), list(...)),
    fn = "RFormula",
    has_fit = TRUE
  )
}
#' @export
ft_r_formula.ml_connect_pipeline <- ft_r_formula_impl
#' @export
ft_r_formula.pyspark_connection <- ft_r_formula_impl
#' @export
ft_r_formula.tbl_pyspark <- ft_r_formula_impl
