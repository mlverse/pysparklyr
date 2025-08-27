# ------------------------------- Bucketizer -----------------------------------
ft_bucketizer_impl <- function(
    x, input_col = NULL, output_col = NULL,
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

# ----------------------------- Tokenizer --------------------------------------

ft_tokenizer_impl <- function(x, input_col = NULL, output_col = NULL,
                              uid = NULL, ...) {
  ml_process_fn(
    args = c(as.list(environment()), list(...)),
    fn = "Tokenizer",
    has_fit = FALSE
  )
}
#' @export
ft_tokenizer.ml_connect_pipeline <- ft_tokenizer_impl
#' @export
ft_tokenizer.pyspark_connection <- ft_tokenizer_impl
#' @export
ft_tokenizer.tbl_pyspark <- ft_tokenizer_impl

# -------------------------- Stop words remover --------------------------------

ft_stop_words_remover_impl <- function(
    x, input_col = NULL, output_col = NULL,
    case_sensitive = FALSE,
    stop_words = NULL,
    uid = NULL, ...) {
  # TODO: Add way to set stop_words same way as regular sparklyr calls
  # not needed before release
  ml_process_fn(
    args = c(as.list(environment()), list(...)),
    fn = "StopWordsRemover",
    has_fit = FALSE
  )
}
#' @export
ft_stop_words_remover.ml_connect_pipeline <- ft_stop_words_remover_impl
#' @export
ft_stop_words_remover.pyspark_connection <- ft_stop_words_remover_impl
#' @export
ft_stop_words_remover.tbl_pyspark <- ft_stop_words_remover_impl

# ----------------------- Hashing term frequencies  ----------------------------

ft_hashing_tf_impl <- function(
    x, input_col = NULL, output_col = NULL, binary = FALSE,
    num_features = 2^18, uid = NULL, ...) {
  ml_process_fn(
    args = c(as.list(environment()), list(...)),
    fn = "HashingTF",
    has_fit = FALSE
  )
}
#' @export
ft_hashing_tf.ml_connect_pipeline <- ft_hashing_tf_impl
#' @export
ft_hashing_tf.pyspark_connection <- ft_hashing_tf_impl
#' @export
ft_hashing_tf.tbl_pyspark <- ft_hashing_tf_impl

# ------------------------------ Normalizer  -----------------------------------

ft_normalizer_impl <- function(
    x, input_col = NULL, output_col = NULL,
    p = 2, uid = NULL, ...) {
  ml_process_fn(
    args = c(as.list(environment()), list(...)),
    fn = "Normalizer",
    has_fit = FALSE
  )
}
#' @export
ft_normalizer.ml_connect_pipeline <- ft_normalizer_impl
#' @export
ft_normalizer.pyspark_connection <- ft_normalizer_impl
#' @export
ft_normalizer.tbl_pyspark <- ft_normalizer_impl

# ---------------------------- String Indexer  ---------------------------------

ft_string_indexer_impl <- function(
    x, input_col = NULL, output_col = NULL,
    handle_invalid = "error", string_order_type = "frequencyDesc",
    uid = NULL, ...) {
  ml_process_fn(
    args = c(as.list(environment()), list(...)),
    fn = "StringIndexer",
    has_fit = TRUE
  )
}
#' @export
ft_string_indexer.ml_connect_pipeline <- ft_string_indexer_impl
#' @export
ft_string_indexer.pyspark_connection <- ft_string_indexer_impl
#' @export
ft_string_indexer.tbl_pyspark <- ft_string_indexer_impl
