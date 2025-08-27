# -------------------------- Linear Regression  --------------------------------
ml_linear_regression_impl <- function(
    x, formula = NULL, fit_intercept = TRUE,
    elastic_net_param = 0, reg_param = 0,
    max_iter = 100, weight_col = NULL,
    loss = "squaredError", solver = "auto",
    standardization = TRUE, tol = 1e-6,
    features_col = "features", label_col = "label",
    prediction_col = "prediction",
    uid = NULL, ...) {
  ml_process_fn(
    args = c(as.list(environment()), list(...)),
    fn = "LinearRegression",
    has_fit = TRUE,
    ml_type = "regression",
    ml_fn = "linear_regression"
  )
}
#' @export
ml_linear_regression.pyspark_connection <- ml_linear_regression_impl
#' @export
ml_linear_regression.ml_connect_pipeline <- ml_linear_regression_impl
#' @export
ml_linear_regression.tbl_pyspark <- ml_linear_regression_impl
#' @export
ml_title.ml_model_linear_regression <- function(x) {
  "Linear Regression"
}

# ----------------------- Random Forest Classifier  ----------------------------

ml_random_forest_classifier_impl <- function(
    x, formula = NULL, num_trees = 10, subsampling_rate = 1,
    max_depth = 5, min_instances_per_node = 1,
    feature_subset_strategy = "auto", impurity = "gini",
    min_info_gain = 0, max_bins = 32, seed = NULL,
    thresholds = NULL, checkpoint_interval = 10, cache_node_ids = FALSE,
    max_memory_in_mb = NULL, features_col = "features",
    label_col = "label", prediction_col = "prediction",
    probability_col = "probability", raw_prediction_col = "rawPrediction",
    uid = NULL, ...) {
  ml_process_fn(
    args = c(as.list(environment()), list(...)),
    fn = "RandomForestClassifier",
    has_fit = TRUE,
    ml_type = "classification",
    ml_fn = "random_forest_classifier"
  )
}
#' @export
ml_random_forest_classifier.pyspark_connection <- ml_random_forest_classifier_impl
#' @export
ml_random_forest_classifier.ml_connect_pipeline <- ml_random_forest_classifier_impl
#' @export
ml_random_forest_classifier.tbl_pyspark <- ml_random_forest_classifier_impl
#' @export
ml_title.ml_model_random_forest_classifier <- function(x) {
  "Linear Regression"
}
