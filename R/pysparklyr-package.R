#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @import cli
#' @import DBI
#' @import dbplyr
#' @import fs
#' @import glue
#' @import httr2
#' @import reticulate
#' @importFrom dplyr filter mutate
#' @importFrom dplyr sample_n sample_frac slice_sample select tbl_ptype group_by
#' @importFrom dplyr tbl collect tibble same_src compute as_tibble group_vars
#' @importFrom glue glue
#' @importFrom lifecycle deprecated
#' @importFrom methods new is setOldClass
#' @importFrom processx process
#' @importFrom purrr map_chr discard transpose reduce map2 list_rbind flatten
#' @importFrom purrr map_lgl map_chr map pmap_chr imap iwalk walk imap_chr as_mapper
#' @importFrom rlang enquo `!!` `!!!` quo_is_null sym warn abort `%||%`
#' @importFrom rlang exec arg_match as_utf8_character is_missing
#' @importFrom rlang is_string is_character parse_exprs set_names
#' @importFrom rstudioapi jobRunScript showQuestion getSourceEditorContext
#' @importFrom sparklyr ft_bucketed_random_projection_lsh ft_count_vectorizer ft_dct
#' @importFrom sparklyr ft_discrete_cosine_transform ft_vector_assembler ft_elementwise_product
#' @importFrom sparklyr ft_feature_hasher ft_idf ft_imputer ft_index_to_string
#' @importFrom sparklyr ft_interaction ft_min_max_scaler ft_minhash_lsh ft_ngram
#' @importFrom sparklyr ft_one_hot_encoder ft_pca ft_polynomial_expansion
#' @importFrom sparklyr ft_quantile_discretizer ft_regex_tokenizer ft_robust_scaler
#' @importFrom sparklyr ft_sql_transformer ft_vector_indexer ft_vector_slicer ft_word2vec
#' @importFrom sparklyr ft_tokenizer ft_stop_words_remover ft_hashing_tf ft_normalizer
#' @importFrom sparklyr ml_binary_classification_evaluator ml_cross_validator
#' @importFrom sparklyr ml_clustering_evaluator ml_regression_evaluator ml_kmeans
#' @importFrom sparklyr ml_decision_tree_regressor ml_bisecting_kmeans ml_aft_survival_regression
#' @importFrom sparklyr ml_gbt_classifier ml_gbt_regressor ml_isotonic_regression
#' @importFrom sparklyr ml_generalized_linear_regression
#' @importFrom sparklyr ml_linear_regression ft_r_formula ft_binarizer ft_bucketizer
#' @importFrom sparklyr ml_logistic_regression ft_standard_scaler ft_max_abs_scaler
#' @importFrom sparklyr ml_multiclass_classification_evaluator ml_decision_tree_classifier
#' @importFrom sparklyr ml_pipeline ml_predict ml_transform ml_fit
#' @importFrom sparklyr ml_random_forest_classifier ml_random_forest_regressor ft_string_indexer
#' @importFrom sparklyr ml_save ml_load spark_jobj spark_install_find spark_apply
#' @importFrom sparklyr sdf_copy_to spark_connect_method spark_log random_string
#' @importFrom sparklyr spark_connection connection_is_open hive_context
#' @importFrom sparklyr spark_dataframe spark_web sdf_register sdf_schema
#' @importFrom sparklyr spark_ide_connection_updated spark_version
#' @importFrom sparklyr spark_ide_objects spark_ide_columns sdf_read_column
#' @importFrom sparklyr spark_read_csv spark_read_parquet spark_read_text
#' @importFrom sparklyr spark_read_json spark_read_orc
#' @importFrom sparklyr spark_session invoke invoke_new invoke_static
#' @importFrom sparklyr spark_table_name spark_integ_test_skip spark_ide_preview
#' @importFrom sparklyr spark_write_csv spark_write_parquet spark_write_text
#' @importFrom sparklyr spark_write_delta
#' @importFrom sparklyr spark_write_orc spark_write_json spark_write_table
#' @importFrom stats terms setNames
#' @importFrom tidyr pivot_longer
#' @importFrom tidyselect matches
#' @importFrom tidyselect tidyselect_data_has_predicates
#' @importFrom utils capture.output installed.packages menu
#' @importFrom utils head type.convert compareVersion
#' @importFrom vctrs vec_as_names
#' @importFrom connectcreds has_viewer_token connect_viewer_token
## usethis namespace: end

## mockable bindings: start
## mockable bindings: end
NULL

globalVariables("RStudio.Version")

pysparklyr_env <- new.env()
pysparklyr_env$temp_prefix <- "sparklyr_tmp_"
temp_prefix <- function() pysparklyr_env$temp_prefix
pysparklyr_env$ml_libraries <- c("torch", "torcheval", "scikit-learn")
