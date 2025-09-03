# ----------------------------- Binarizer --------------------------------------
ft_binarizer_impl <- function(
    x, input_col, output_col, threshold = 0, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "Binarizer", FALSE)
}
#' @export
ft_binarizer.ml_connect_pipeline <- ft_binarizer_impl
#' @export
ft_binarizer.pyspark_connection <- ft_binarizer_impl
#' @export
ft_binarizer.tbl_pyspark <- ft_binarizer_impl

# ------------------------------- Bucketizer -----------------------------------
ft_bucketizer_impl <- function(
    x, input_col = NULL, output_col = NULL, splits = NULL, input_cols = NULL,
    output_cols = NULL, splits_array = NULL, handle_invalid = "error",
    uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "Bucketizer", FALSE)
}
#' @export
ft_bucketizer.ml_connect_pipeline <- ft_bucketizer_impl
#' @export
ft_bucketizer.pyspark_connection <- ft_bucketizer_impl
#' @export
ft_bucketizer.tbl_pyspark <- ft_bucketizer_impl

# ---------------------- Bucket Random Projection LSH --------------------------
ft_bucketed_random_projection_lsh_impl <- function(
    x, input_col = NULL, output_col = NULL, bucket_length = NULL,
    num_hash_tables = 1, seed = NULL, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "BucketedRandomProjectionLSH", TRUE)
}
#' @export
ft_bucketed_random_projection_lsh.ml_connect_pipeline <- ft_bucketed_random_projection_lsh_impl
#' @export
ft_bucketed_random_projection_lsh.pyspark_connection <- ft_bucketed_random_projection_lsh_impl
#' @export
ft_bucketed_random_projection_lsh.tbl_pyspark <- ft_bucketed_random_projection_lsh_impl

# ----------------------------- Count vectorizer -------------------------------
ft_count_vectorizer_impl <- function(
    x, input_col = NULL, output_col = NULL, binary = FALSE, min_df = NULL,
    min_tf = NULL, vocab_size = 2^18, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "CountVectorizer", TRUE)
}
#' @export
ft_count_vectorizer.ml_connect_pipeline <- ft_count_vectorizer_impl
#' @export
ft_count_vectorizer.pyspark_connection <- ft_count_vectorizer_impl
#' @export
ft_count_vectorizer.tbl_pyspark <- ft_count_vectorizer_impl

# ---------------------------------- DCT  --------------------------------------
ft_dct_impl <- function(
    x, input_col = NULL, output_col = NULL, inverse = FALSE, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "DCT", FALSE)
}
#' @export
ft_dct.ml_connect_pipeline <- ft_dct_impl
#' @export
ft_dct.pyspark_connection <- ft_dct_impl
#' @export
ft_dct.tbl_pyspark <- ft_dct_impl
#' @export
ft_discrete_cosine_transform.ml_connect_pipeline <- ft_dct_impl
#' @export
ft_discrete_cosine_transform.pyspark_connection <- ft_dct_impl
#' @export
ft_discrete_cosine_transform.tbl_pyspark <- ft_dct_impl

# -------------------------- Elementwise Product  ------------------------------
ft_elementwise_product_impl <- function(
    x, input_col = NULL, output_col = NULL, scaling_vec = NULL, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "ElementwiseProduct", FALSE)
}
#' @export
ft_elementwise_product.ml_connect_pipeline <- ft_elementwise_product_impl
#' @export
ft_elementwise_product.pyspark_connection <- ft_elementwise_product_impl
#' @export
ft_elementwise_product.tbl_pyspark <- ft_elementwise_product_impl


# ---------------------------- Feature Hasher  ---------------------------------
ft_feature_hasher_impl <- function(
    x, input_cols = NULL, output_col = NULL,
    num_features = 2^18, categorical_cols = NULL, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "FeatureHasher", FALSE)
}
#' @export
ft_feature_hasher.ml_connect_pipeline <- ft_feature_hasher_impl
#' @export
ft_feature_hasher.pyspark_connection <- ft_feature_hasher_impl
#' @export
ft_feature_hasher.tbl_pyspark <- ft_feature_hasher_impl

# ----------------------- Hashing term frequencies  ----------------------------

ft_hashing_tf_impl <- function(
    x, input_col = NULL, output_col = NULL, binary = FALSE,
    num_features = 2^18, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "HashingTF", FALSE)
}
#' @export
ft_hashing_tf.ml_connect_pipeline <- ft_hashing_tf_impl
#' @export
ft_hashing_tf.pyspark_connection <- ft_hashing_tf_impl
#' @export
ft_hashing_tf.tbl_pyspark <- ft_hashing_tf_impl

# -------------------- Inverse document frequency  -----------------------------
ft_idf_impl <- function(
    x, input_col = NULL, output_col = NULL, min_doc_freq = 0, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "IDF", TRUE)
}
#' @export
ft_idf.ml_connect_pipeline <- ft_idf_impl
#' @export
ft_idf.pyspark_connection <- ft_idf_impl
#' @export
ft_idf.tbl_pyspark <- ft_idf_impl

# -------------------------------- Imputer  ------------------------------------
ft_imputer_impl <- function(
    x, input_cols = NULL, output_cols = NULL, missing_value = NULL,
    strategy = "mean", uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "Imputer", TRUE)
}
#' @export
ft_imputer.ml_connect_pipeline <- ft_imputer_impl
#' @export
ft_imputer.pyspark_connection <- ft_imputer_impl
#' @export
ft_imputer.tbl_pyspark <- ft_imputer_impl

# ------------------------- Index to string  -----------------------------------
ft_index_to_string_impl <- function(
    x, input_col = NULL, output_col = NULL, labels = NULL, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "IndexToString", FALSE)
}
#' @export
ft_index_to_string.ml_connect_pipeline <- ft_index_to_string_impl
#' @export
ft_index_to_string.pyspark_connection <- ft_index_to_string_impl
#' @export
ft_index_to_string.tbl_pyspark <- ft_index_to_string_impl

# ----------------------------- Interaction  -----------------------------------
ft_interaction_impl <- function(x, input_cols = NULL, output_col = NULL,
                                uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "Interaction", FALSE)
}
#' @export
ft_interaction.ml_connect_pipeline <- ft_interaction_impl
#' @export
ft_interaction.pyspark_connection <- ft_interaction_impl
#' @export
ft_interaction.tbl_pyspark <- ft_interaction_impl

# --------------------------- Min Max Scaler  ----------------------------------
ft_min_max_scaler_impl <- function(
    x, input_col = NULL, output_col = NULL, min = 0, max = 1, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "MinMaxScaler", TRUE)
}
#' @export
ft_min_max_scaler.ml_connect_pipeline <- ft_min_max_scaler_impl
#' @export
ft_min_max_scaler.pyspark_connection <- ft_min_max_scaler_impl
#' @export
ft_min_max_scaler.tbl_pyspark <- ft_min_max_scaler_impl

# --------------------------- Min Hash LSH  ----------------------------------
ft_minhash_lsh_impl <- function(
    x, input_col = NULL, output_col = NULL, num_hash_tables = 1L, seed = NULL,
    uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "MinHashLSH", TRUE)
}
#' @export
ft_minhash_lsh.ml_connect_pipeline <- ft_minhash_lsh_impl
#' @export
ft_minhash_lsh.pyspark_connection <- ft_minhash_lsh_impl
#' @export
ft_minhash_lsh.tbl_pyspark <- ft_minhash_lsh_impl

# -------------------------------- N-gram  -------------------------------------
ft_ngram_impl <- function(
    x, input_col = NULL, output_col = NULL, n = 2,
    uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "NGram", FALSE)
}
#' @export
ft_ngram.ml_connect_pipeline <- ft_ngram_impl
#' @export
ft_ngram.pyspark_connection <- ft_ngram_impl
#' @export
ft_ngram.tbl_pyspark <- ft_ngram_impl

# ------------------------------ Normalizer  -----------------------------------
ft_normalizer_impl <- function(
    x, input_col = NULL, output_col = NULL, p = 2, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "Normalizer", FALSE)
}
#' @export
ft_normalizer.ml_connect_pipeline <- ft_normalizer_impl
#' @export
ft_normalizer.pyspark_connection <- ft_normalizer_impl
#' @export
ft_normalizer.tbl_pyspark <- ft_normalizer_impl

# --------------------------- One hot encoder  ---------------------------------
ft_one_hot_encoder_impl <- function(
    x, input_cols = NULL, output_cols = NULL,
    handle_invalid = NULL, drop_last = TRUE, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "OneHotEncoder", TRUE)
}
#' @export
ft_one_hot_encoder.ml_connect_pipeline <- ft_one_hot_encoder_impl
#' @export
ft_one_hot_encoder.pyspark_connection <- ft_one_hot_encoder_impl
#' @export
ft_one_hot_encoder.tbl_pyspark <- ft_one_hot_encoder_impl

# --------------------------------- PCA  ---------------------------------------
ft_pca_impl <- function(
    x, input_col = NULL, output_col = NULL, k = NULL, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "PCA", TRUE)
}
#' @export
ft_pca.ml_connect_pipeline <- ft_pca_impl
#' @export
ft_pca.pyspark_connection <- ft_pca_impl
#' @export
ft_pca.tbl_pyspark <- ft_pca_impl

# ------------------------- Polynomial Expansion  ------------------------------
ft_polynomial_expansion_impl <- function(
    x, input_col = NULL, output_col = NULL, degree = 2, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "PolynomialExpansion", FALSE)
}
#' @export
ft_polynomial_expansion.ml_connect_pipeline <- ft_polynomial_expansion_impl
#' @export
ft_polynomial_expansion.pyspark_connection <- ft_polynomial_expansion_impl
#' @export
ft_polynomial_expansion.tbl_pyspark <- ft_polynomial_expansion_impl

# ----------------------- Quantile Discretizer  ---------------------------------
ft_quantile_discretizer_impl <- function(
    x, input_col = NULL, output_col = NULL, num_buckets = 2, input_cols = NULL,
    output_cols = NULL, num_buckets_array = NULL, handle_invalid = "error",
    relative_error = 0.001, uid = NULL, weight_column = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "QuantileDiscretizer", TRUE)
}
#' @export
ft_quantile_discretizer.ml_connect_pipeline <- ft_quantile_discretizer_impl
#' @export
ft_quantile_discretizer.pyspark_connection <- ft_quantile_discretizer_impl
#' @export
ft_quantile_discretizer.tbl_pyspark <- ft_quantile_discretizer_impl


# ----------------------------- RFormula ---------------------------------------
ft_r_formula_impl <- function(
    x, formula = NULL, features_col = "features", label_col = "label",
    force_index_label = FALSE, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "RFormula", TRUE)
}
#' @export
ft_r_formula.ml_connect_pipeline <- ft_r_formula_impl
#' @export
ft_r_formula.pyspark_connection <- ft_r_formula_impl
#' @export
ft_r_formula.tbl_pyspark <- ft_r_formula_impl

# --------------------------- Regex Tokenizer  ---------------------------------
ft_regex_tokenizer_impl <- function(
    x, input_col = NULL, output_col = NULL, gaps = TRUE, min_token_length = 1,
    pattern = "\\s+", to_lower_case = NULL, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "RegexTokenizer", FALSE)
}
#' @export
ft_regex_tokenizer.ml_connect_pipeline <- ft_regex_tokenizer_impl
#' @export
ft_regex_tokenizer.pyspark_connection <- ft_regex_tokenizer_impl
#' @export
ft_regex_tokenizer.tbl_pyspark <- ft_regex_tokenizer_impl

# --------------------------- Robust Scaler  -----------------------------------
ft_robust_scaler_impl <- function(
    x, input_col = NULL, output_col = NULL,
    lower = 0.25, upper = 0.75, with_centering = TRUE,
    with_scaling = TRUE, relative_error = 0.001, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "RobustScaler", TRUE)
}
#' @export
ft_robust_scaler.ml_connect_pipeline <- ft_robust_scaler_impl
#' @export
ft_robust_scaler.pyspark_connection <- ft_robust_scaler_impl
#' @export
ft_robust_scaler.tbl_pyspark <- ft_robust_scaler_impl

# --------------------------------- SQL  ---------------------------------------
ft_sql_transformer_impl <- function(x, statement = NULL, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "SQLTransformer", FALSE)
}
#' @export
ft_sql_transformer.ml_connect_pipeline <- ft_sql_transformer_impl
#' @export
ft_sql_transformer.pyspark_connection <- ft_sql_transformer_impl
#' @export
ft_sql_transformer.tbl_pyspark <- ft_sql_transformer_impl

# -------------------------- Stop words remover --------------------------------

ft_stop_words_remover_impl <- function(
    x, input_col = NULL, output_col = NULL, case_sensitive = FALSE,
    stop_words = NULL, uid = NULL, ...) {
  # TODO: Add way to set stop_words same way as regular sparklyr calls
  # not needed before release
  ml_process_transformer(c(as.list(environment()), list(...)), "StopWordsRemover", FALSE)
}
#' @export
ft_stop_words_remover.ml_connect_pipeline <- ft_stop_words_remover_impl
#' @export
ft_stop_words_remover.pyspark_connection <- ft_stop_words_remover_impl
#' @export
ft_stop_words_remover.tbl_pyspark <- ft_stop_words_remover_impl

# ---------------------------- String Indexer  ---------------------------------

ft_string_indexer_impl <- function(
    x, input_col = NULL, output_col = NULL, handle_invalid = "error",
    string_order_type = "frequencyDesc", uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "StringIndexer", TRUE)
}
#' @export
ft_string_indexer.ml_connect_pipeline <- ft_string_indexer_impl
#' @export
ft_string_indexer.pyspark_connection <- ft_string_indexer_impl
#' @export
ft_string_indexer.tbl_pyspark <- ft_string_indexer_impl

# ----------------------------- Tokenizer --------------------------------------
ft_tokenizer_impl <- function(
    x, input_col = NULL, output_col = NULL, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "Tokenizer", FALSE)
}
#' @export
ft_tokenizer.ml_connect_pipeline <- ft_tokenizer_impl
#' @export
ft_tokenizer.pyspark_connection <- ft_tokenizer_impl
#' @export
ft_tokenizer.tbl_pyspark <- ft_tokenizer_impl

# -------------------------- Vector Assembler ----------------------------------
ft_vector_assembler_impl <- function(
    x, input_cols = NULL, output_col = NULL, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "VectorAssembler", FALSE)
}
#' @export
ft_vector_assembler.ml_connect_pipeline <- ft_vector_assembler_impl
#' @export
ft_vector_assembler.pyspark_connection <- ft_vector_assembler_impl
#' @export
ft_vector_assembler.tbl_pyspark <- ft_vector_assembler_impl

# ---------------------------- Vector Indexer ----------------------------------
ft_vector_indexer_impl <- function(
    x, input_col = NULL, output_col = NULL, handle_invalid = "error",
    max_categories = 20, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "VectorIndexer", TRUE)
}
#' @export
ft_vector_indexer.ml_connect_pipeline <- ft_vector_indexer_impl
#' @export
ft_vector_indexer.pyspark_connection <- ft_vector_indexer_impl
#' @export
ft_vector_indexer.tbl_pyspark <- ft_vector_indexer_impl

# ---------------------------- Vector Slicer ----------------------------------
ft_vector_slicer_impl <- function(
    x, input_col = NULL, output_col = NULL, indices = NULL, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "VectorSlicer", FALSE)
}
#' @export
ft_vector_slicer.ml_connect_pipeline <- ft_vector_slicer_impl
#' @export
ft_vector_slicer.pyspark_connection <- ft_vector_slicer_impl
#' @export
ft_vector_slicer.tbl_pyspark <- ft_vector_slicer_impl

# ------------------------------- Word2Vec -------------------------------------
ft_word2vec_impl <- function(
    x, input_col = NULL, output_col = NULL, vector_size = 100, min_count = 5,
    max_sentence_length = 1000, num_partitions = 1, step_size = 0.025,
    max_iter = 1, seed = NULL, uid = NULL, ...) {
  ml_process_transformer(c(as.list(environment()), list(...)), "Word2Vec", TRUE)
}
#' @export
ft_word2vec.ml_connect_pipeline <- ft_word2vec_impl
#' @export
ft_word2vec.pyspark_connection <- ft_word2vec_impl
#' @export
ft_word2vec.tbl_pyspark <- ft_word2vec_impl
