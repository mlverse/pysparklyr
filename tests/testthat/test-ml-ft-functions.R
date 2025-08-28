skip_on_ci()
skip_spark_min_version(4.0)

test_that("Binarizer works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  expect_snapshot(class(ft_binarizer(sc, "a", "b")))
  expect_snapshot(class(ft_binarizer(ml_pipeline(sc), "a", "b")))
  x <- ft_binarizer(tbl_mtcars, "mpg", "mpg_new", threshold = 20)
  expect_snapshot(class(x))
  expect_equal(
    dplyr::pull(dplyr::summarise(x, sum(mpg_new, na.rm = TRUE))),
    14
  )
})

test_that("Bucket Random Projection LSH works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_bucketed_random_projection_lsh(sc, "a", "b")))
  expect_snapshot(class(ft_bucketed_random_projection_lsh(ml_pipeline(sc), "a", "b")))
  tbl_reviews <- use_test_table_reviews()
  x <- use_test_table_iris() %>%
    ft_vector_assembler(
      input_cols = c("Sepal_Length", "Sepal_Width", "Petal_Length"),
      output_col = "vec_x"
    ) %>%
    ft_bucketed_random_projection_lsh("vec_x", "lsh_x", bucket_length = 1)
  expect_snapshot(dplyr::pull(x))
  expect_snapshot(class(x))
})

test_that("Bucketizer works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  expect_snapshot(class(ft_bucketizer(sc, "a", "b", c(1, 2, 3))))
  expect_snapshot(class(ft_bucketizer(ml_pipeline(sc), "a", "b", c(1, 2, 3))))
  x <- ft_bucketizer(tbl_mtcars, "mpg", "mpg_new", splits = c(0, 10, 20, 30, 40))
  expect_snapshot(class(x))
  expect_equal(
    dplyr::pull(dplyr::summarise(x, sum(mpg_new, na.rm = TRUE))),
    50
  )
})

test_that("Count vectorizer works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_count_vectorizer(sc, "a", "b")))
  expect_snapshot(class(ft_count_vectorizer(ml_pipeline(sc), "a", "b")))
  tbl_reviews <- use_test_table_reviews()
  x <- tbl_reviews %>%
    ft_tokenizer(input_col = "x", output_col = "token_x") %>%
    ft_count_vectorizer("token_x", "cv_x")
  expect_snapshot(class(x))
  expect_snapshot(dplyr::pull(x))
})

test_that("DCT works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_dct(sc, "a", "b")))
  expect_snapshot(class(ft_dct(ml_pipeline(sc), "a", "b")))
  x <- use_test_table_iris() %>%
    ft_vector_assembler(
      input_cols = c("Sepal_Length", "Sepal_Width", "Petal_Length"),
      output_col = "vec_x"
    ) %>%
    ft_dct("vec_x", "dct_x")
  expect_snapshot(class(x))
  expect_snapshot(dplyr::pull(x))
})

test_that("Discrete Cosine works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_discrete_cosine_transform(sc, "a", "b")))
  expect_snapshot(class(ft_discrete_cosine_transform(ml_pipeline(sc), "a", "b")))
  x <- use_test_table_iris() %>%
    ft_vector_assembler(
      input_cols = c("Sepal_Length", "Sepal_Width", "Petal_Length"),
      output_col = "vec_x"
    ) %>%
    ft_discrete_cosine_transform("vec_x", "dct_x")
  expect_snapshot(class(x))
  expect_snapshot(dplyr::pull(x))
})

test_that("Elementwise Product works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_elementwise_product(sc, "a", "b")))
  expect_snapshot(class(ft_elementwise_product(ml_pipeline(sc), "a", "b")))
  x <- use_test_table_iris() %>%
    ft_vector_assembler(
      input_cols = c("Sepal_Length", "Sepal_Width", "Petal_Length"),
      output_col = "vec_x"
    ) %>%
    ft_elementwise_product("vec_x", "elm_x", scaling_vec = c(1:3))
  expect_snapshot(class(x))
  expect_snapshot(dplyr::pull(x))
})

test_that("Feature Hasher works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_feature_hasher(sc)))
  expect_snapshot(class(ft_feature_hasher(ml_pipeline(sc))))
  x <- use_test_table_iris() %>%
    ft_feature_hasher(c("Species", "Sepal_Width", "Petal_Length"), "hash_x")
  expect_snapshot(class(x))
  expect_snapshot(dplyr::pull(x))
})

test_that("Hashing TF works", {
  sc <- use_test_spark_connect()
  tbl_reviews <- use_test_table_reviews()
  expect_snapshot(class(ft_hashing_tf(ml_pipeline(sc))))
  expect_snapshot(class(ft_hashing_tf(sc)))
  x <- tbl_reviews %>%
    ft_tokenizer(input_col = "x", output_col = "token_x") %>%
    ft_stop_words_remover(input_col = "token_x", output_col = "stop_x") %>%
    ft_hashing_tf(
      input_col = "stop_x",
      output_col = "hashed_x",
      binary = TRUE,
      num_features = 1024
    )
  expect_snapshot(class(x))
  expect_snapshot(dplyr::pull(x, hashed_x))
})

test_that("IDF works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_idf(sc, "a", "b")))
  expect_snapshot(class(ft_idf(ml_pipeline(sc), "a", "b")))
  x <- use_test_table_iris() %>%
    ft_vector_assembler(
      input_cols = c("Sepal_Length", "Sepal_Width", "Petal_Length"),
      output_col = "vec_x"
    ) %>%
    ft_idf("vec_x", "idf_x")
  expect_snapshot(class(x))
  expect_snapshot(dplyr::pull(x))
})

test_that("Imputer works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_imputer(sc)))
  expect_snapshot(class(ft_imputer(ml_pipeline(sc))))
  x <- use_test_table(
    x = data.frame(x = c(2, 2, 4, NA, 4), y = 1:5),
    name = "imputer"
  ) %>%
    ft_imputer(list(c("x")), list(c("new_x")))
  expect_snapshot(class(x))
  expect_equal(dplyr::pull(x), c(2, 2, 4, 3, 4))
})

test_that("Index-to-string works", {
  sc <- use_test_spark_connect()
  tbl_iris <- use_test_table_iris()
  expect_snapshot(class(ft_index_to_string(ml_pipeline(sc))))
  expect_snapshot(class(ft_index_to_string(sc)))
  x <- tbl_iris %>%
    ft_string_indexer("Species", "species_idx") %>%
    ft_index_to_string("species_idx", "species_x")
  expect_snapshot(class(x))
  expect_snapshot(table(dplyr::pull(x)))
})

test_that("Interaction works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_interaction(sc)))
  expect_snapshot(class(ft_interaction(ml_pipeline(sc))))
  x <- use_test_table_mtcars() %>%
    ft_interaction(c("mpg", "wt"), c("mpg_wt"))
  expect_snapshot(class(x))
  expect_snapshot(dplyr::pull(x))
})

test_that("Min-max scaler works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_min_max_scaler(sc, "a", "b")))
  expect_snapshot(class(ft_min_max_scaler(ml_pipeline(sc), "a", "b")))
  x <- use_test_table_iris() %>%
    ft_vector_assembler(
      input_cols = c("Sepal_Length", "Sepal_Width", "Petal_Length"),
      output_col = "vec_x"
    ) %>%
    ft_min_max_scaler("vec_x", "scaler_x")
  expect_snapshot(class(x))
  expect_snapshot(dplyr::pull(x))
})


test_that("R Formula works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_r_formula(ml_pipeline(sc))))
  expect_snapshot(class(ft_r_formula(sc)))
  expect_snapshot(
    ft_r_formula(
      use_test_table_mtcars(),
      mpg ~ .,
      features_col = "test"
    ) %>%
      colnames()
  )
})

test_that("Tokenizer works", {
  sc <- use_test_spark_connect()
  tbl_reviews <- use_test_table_reviews()
  expect_snapshot(class(ft_tokenizer(ml_pipeline(sc))))
  expect_snapshot(class(ft_tokenizer(sc)))
  x <- ft_tokenizer(tbl_reviews, input_col = "x", output_col = "token_x")
  expect_snapshot(class(x))
  expect_snapshot(dplyr::pull(x, token_x))
})

test_that("Stop words remover works", {
  sc <- use_test_spark_connect()
  tbl_reviews <- use_test_table_reviews()
  expect_snapshot(class(ft_tokenizer(ml_pipeline(sc))))
  expect_snapshot(class(ft_tokenizer(sc)))
  x <- tbl_reviews %>%
    ft_tokenizer(input_col = "x", output_col = "token_x") %>%
    ft_stop_words_remover(input_col = "token_x", output_col = "stop_x")
  expect_snapshot(class(x))
  expect_snapshot(dplyr::pull(x, stop_x))
})

test_that("Normalizer works", {
  sc <- use_test_spark_connect()
  tbl_reviews <- use_test_table_reviews()
  expect_snapshot(class(ft_hashing_tf(ml_pipeline(sc))))
  expect_snapshot(class(ft_hashing_tf(sc)))
  x <- tbl_reviews %>%
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
    )
  expect_snapshot(class(x))
  expect_snapshot(dplyr::pull(x, normal_x))
})

test_that("String indexer works", {
  sc <- use_test_spark_connect()
  tbl_iris <- use_test_table_iris()
  expect_snapshot(class(ft_string_indexer(ml_pipeline(sc))))
  expect_snapshot(class(ft_string_indexer(sc)))
  x <- tbl_iris %>%
    ft_string_indexer("Species", "species_idx")
  expect_snapshot(class(x))
  expect_snapshot(table(dplyr::pull(x)))
})

test_that("Vector assembler works", {
  sc <- use_test_spark_connect()
  expect_snapshot(class(ft_vector_assembler(ml_pipeline(sc))))
  expect_snapshot(class(ft_vector_assembler(sc)))
  x <- use_test_table_iris() %>%
    ft_vector_assembler(
      input_cols = c("Sepal_Length", "Sepal_Width", "Petal_Length"),
      output_col = "vec_x"
    )
  expect_snapshot(class(x))
  expect_snapshot(dplyr::pull(x))
})
