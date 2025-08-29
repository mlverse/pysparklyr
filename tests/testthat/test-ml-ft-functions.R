skip_on_ci()
skip_spark_min_version(4.0)

test_that("Binarizer works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_binarizer(sc, "a", "b")))
  expect_snapshot(class(ft_binarizer(ml_pipeline(sc), "a", "b")))
  expect_snapshot(
    use_test_table_mtcars() %>%
      ft_binarizer("mpg", "mpg_new", threshold = 20) %>%
      use_test_pull(TRUE)
  )
})

test_that("Bucket Random Projection LSH works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_bucketed_random_projection_lsh(sc)))
  expect_snapshot(
    class(ft_bucketed_random_projection_lsh(ml_pipeline(sc)))
  )
  expect_snapshot(
    use_test_mtcars_va() %>%
      ft_bucketed_random_projection_lsh("vec_x", "lsh_x", bucket_length = 1) %>%
      use_test_pull()
  )
})

test_that("Bucketizer works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_bucketizer(sc, "a", "b", c(1, 2, 3))))
  expect_snapshot(class(ft_bucketizer(ml_pipeline(sc), "a", "b", c(1, 2, 3))))
  expect_snapshot(
    use_test_table_mtcars() %>%
      ft_bucketizer("mpg", "mpg_new", splits = c(0, 10, 20, 30, 40)) %>%
      use_test_pull(TRUE)
  )
})

test_that("Count vectorizer works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_count_vectorizer(sc)))
  expect_snapshot(class(ft_count_vectorizer(ml_pipeline(sc))))
  expect_snapshot(
    use_test_table_reviews() %>%
      ft_tokenizer(input_col = "x", output_col = "token_x") %>%
      ft_count_vectorizer("token_x", "cv_x") %>%
      use_test_pull()
  )
})

test_that("DCT works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_dct(sc)))
  expect_snapshot(class(ft_dct(ml_pipeline(sc))))
  expect_snapshot(
    use_test_mtcars_va() %>%
      ft_dct("vec_x", "dct_x") %>%
      use_test_pull()
  )
})

test_that("Discrete Cosine works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_discrete_cosine_transform(sc)))
  expect_snapshot(class(ft_discrete_cosine_transform(ml_pipeline(sc))))
  expect_snapshot(
    use_test_mtcars_va() %>%
      ft_discrete_cosine_transform("vec_x", "dct_x") %>%
      use_test_pull()
  )
})

test_that("Elementwise Product works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_elementwise_product(sc)))
  expect_snapshot(class(ft_elementwise_product(ml_pipeline(sc))))
  expect_snapshot(
    use_test_mtcars_va() %>%
      ft_elementwise_product("vec_x", "elm_x", scaling_vec = c(1:3)) %>%
      use_test_pull()
  )
})

test_that("Feature Hasher works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_feature_hasher(sc)))
  expect_snapshot(class(ft_feature_hasher(ml_pipeline(sc))))
  expect_snapshot(
    use_test_table_mtcars() %>%
      ft_feature_hasher(c("mpg", "wt", "cyl")) %>%
      use_test_pull()
  )
})

test_that("Hashing TF works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_hashing_tf(ml_pipeline(sc))))
  expect_snapshot(class(ft_hashing_tf(sc)))
  expect_snapshot(
    use_test_table_reviews() %>%
      ft_tokenizer(input_col = "x", output_col = "token_x") %>%
      ft_hashing_tf(
        input_col = "token_x",
        output_col = "hashed_x",
        binary = TRUE,
        num_features = 1024
      ) %>%
      use_test_pull()
  )
})

test_that("IDF works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_idf(sc)))
  expect_snapshot(class(ft_idf(ml_pipeline(sc))))
  expect_snapshot(
    use_test_mtcars_va() %>%
      ft_idf("vec_x", "idf_x") %>%
      use_test_pull()
  )
})

test_that("Imputer works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_imputer(sc)))
  expect_snapshot(class(ft_imputer(ml_pipeline(sc))))
  expect_snapshot(
    use_test_table_simple() %>%
      ft_imputer(list(c("x")), list(c("new_x"))) %>%
      use_test_pull()
  )
})

test_that("Index-to-string works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_index_to_string(ml_pipeline(sc))))
  expect_snapshot(class(ft_index_to_string(sc)))
  expect_snapshot(
    use_test_table_iris() %>%
      ft_string_indexer("Species", "species_idx") %>%
      ft_index_to_string("species_idx", "species_x") %>%
      use_test_pull(TRUE)
  )
})

test_that("Interaction works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_interaction(sc)))
  expect_snapshot(class(ft_interaction(ml_pipeline(sc))))
  expect_snapshot(
    use_test_table_mtcars() %>%
      ft_interaction(c("mpg", "wt"), c("mpg_wt")) %>%
      use_test_pull()
  )
})

test_that("Min Hash LSH works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_minhash_lsh(sc)))
  expect_snapshot(class(ft_minhash_lsh(ml_pipeline(sc))))
  expect_snapshot(
    use_test_iris_va() %>%
      ft_minhash_lsh("vec_x", "hash_x") %>%
      use_test_pull() %>%
      round() %>%
      table()
  )
})

test_that("N-gram works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_ngram(sc)))
  expect_snapshot(class(ft_ngram(ml_pipeline(sc))))
  expect_snapshot(
    use_test_table_reviews() %>%
      ft_tokenizer("x", "token_x") %>%
      ft_ngram("token_x", "ngram_x") %>%
      dplyr::pull()
  )
})

test_that("Normalizer works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_hashing_tf(ml_pipeline(sc))))
  expect_snapshot(class(ft_hashing_tf(sc)))
  expect_snapshot(
    use_test_table_reviews() %>%
      ft_tokenizer(input_col = "x", output_col = "token_x") %>%
      ft_stop_words_remover(input_col = "token_x", output_col = "stop_x") %>%
      ft_hashing_tf(
        input_col = "stop_x",
        output_col = "hashed_x",
        binary = TRUE,
        num_features = 1024
      ) %>%
      ft_normalizer(
        input_col = "hashed_x",
        output_col = "normal_x"
      ) %>%
      use_test_pull()
  )
})

test_that("One hot encoder works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_one_hot_encoder(sc)))
  expect_snapshot(class(ft_one_hot_encoder(ml_pipeline(sc))))
  expect_snapshot(
    use_test_table_simple() %>%
      ft_one_hot_encoder(list(c("y")), list(c("ohe_x"))) %>%
      use_test_pull()
  )
})

test_that("PCA works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_pca(sc)))
  expect_snapshot(class(ft_pca(ml_pipeline(sc))))
  expect_snapshot(
    use_test_mtcars_va() %>%
      ft_pca("vec_x", "pca_x", k = 2) %>%
      use_test_pull()
  )
})

test_that("Polynomial expansion works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_polynomial_expansion(sc)))
  expect_snapshot(class(ft_polynomial_expansion(ml_pipeline(sc))))
  expect_snapshot(
    use_test_mtcars_va() %>%
      ft_polynomial_expansion("vec_x", "pe_x", degree = 2) %>%
      use_test_pull()
  )
})

test_that("Quantile discretizer works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_quantile_discretizer(sc)))
  expect_snapshot(class(ft_quantile_discretizer(ml_pipeline(sc))))
  expect_snapshot(
    use_test_table_simple() %>%
      ft_quantile_discretizer(c("y"), c("ohe_x")) %>%
      use_test_pull()
  )
})

test_that("R Formula works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_r_formula(ml_pipeline(sc))))
  expect_snapshot(class(ft_r_formula(sc)))
  expect_snapshot(
    use_test_table_mtcars() %>%
      ft_r_formula(mpg ~ ., features_col = "test") %>%
      dplyr::select(test) %>%
      use_test_pull()
  )
})

test_that("Regex Tokenizer works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_regex_tokenizer(sc)))
  expect_snapshot(class(ft_regex_tokenizer(ml_pipeline(sc))))
  expect_snapshot(
    use_test_table_reviews() %>%
      ft_regex_tokenizer("x", "new_x") %>%
      dplyr::pull()
  )
})

test_that("Robust Scaler works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_robust_scaler(sc)))
  expect_snapshot(class(ft_robust_scaler(ml_pipeline(sc))))
  expect_snapshot(
    use_test_mtcars_va() %>%
      ft_robust_scaler("vec_x", "rs_x") %>%
      use_test_pull()
  )
})

test_that("SQL transformer works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_sql_transformer(sc)))
  expect_snapshot(class(ft_sql_transformer(ml_pipeline(sc))))
  expect_snapshot(
    use_test_mtcars_va() %>%
      ft_sql_transformer("select * from __THIS__ where mpg > 20") %>%
      use_test_pull()
  )
})

test_that("Stop words remover works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_tokenizer(ml_pipeline(sc))))
  expect_snapshot(class(ft_tokenizer(sc)))
  expect_snapshot(
    use_test_table_reviews() %>%
      ft_tokenizer(input_col = "x", output_col = "token_x") %>%
      ft_stop_words_remover(input_col = "token_x", output_col = "stop_x") %>%
      dplyr::pull()
  )
})

test_that("String indexer works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_string_indexer(ml_pipeline(sc))))
  expect_snapshot(class(ft_string_indexer(sc)))
  expect_snapshot(
    use_test_table_iris() %>%
      ft_string_indexer("Species", "species_idx") %>%
      use_test_pull(TRUE)
  )
})

test_that("Tokenizer works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_tokenizer(ml_pipeline(sc))))
  expect_snapshot(class(ft_tokenizer(sc)))
  expect_snapshot(
    use_test_table_reviews() %>%
      ft_tokenizer(input_col = "x", output_col = "token_x") %>%
      dplyr::pull()
  )
})

test_that("Vector assembler works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_vector_assembler(ml_pipeline(sc))))
  expect_snapshot(class(ft_vector_assembler(sc)))
  expect_snapshot(
    use_test_table_mtcars() %>%
      ft_vector_assembler(
        input_cols = c("mpg", "wt", "cyl"),
        output_col = "vec_x"
      ) %>%
      use_test_pull()
  )
})
