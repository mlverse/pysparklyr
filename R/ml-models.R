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


# ------------------------- Logistic Regression  -------------------------------
ml_logistic_regression_impl <- function(
    x, formula = NULL, fit_intercept = NULL,
    elastic_net_param = NULL, reg_param = NULL, max_iter = 100,
    threshold = NULL, thresholds = NULL, tol = 1e-06,
    weight_col = NULL, aggregation_depth = NULL,
    lower_bounds_on_coefficients = NULL, lower_bounds_on_intercepts = NULL,
    upper_bounds_on_coefficients = NULL, upper_bounds_on_intercepts = NULL,
    features_col = "features", label_col = "label", family = NULL,
    prediction_col = "prediction", probability_col = "probability",
    raw_prediction_col = NULL, uid = NULL, ...) {
  ml_process_fn(
    args = c(as.list(environment()), list(...)),
    fn = "LogisticRegression",
    has_fit = TRUE,
    ml_type = "classification",
    ml_fn = "logistic_regression"
  )
}
#' @export
ml_logistic_regression.pyspark_connection <- ml_logistic_regression_impl
#' @export
ml_logistic_regression.ml_connect_pipeline <- ml_logistic_regression_impl
#' @export
ml_logistic_regression.tbl_pyspark <- ml_logistic_regression_impl

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

# ----------------------- Random Forest Regressor  -----------------------------
ml_random_forest_regressor_impl <- function(
    x, formula = NULL, num_trees = 20, subsampling_rate = 1,
    max_depth = 5, min_instances_per_node = 1, feature_subset_strategy = "auto",
    impurity = "variance", min_info_gain = 0, max_bins = 32,
    seed = NULL, checkpoint_interval = 10, cache_node_ids = FALSE,
    max_memory_in_mb = NULL, features_col = "features", label_col = "label",
    prediction_col = "prediction", uid = NULL, ...) {
  ml_process_fn(
    args = c(as.list(environment()), list(...)),
    fn = "RandomForestRegressor",
    has_fit = TRUE,
    ml_type = "regression",
    ml_fn = "random_forest_regressor"
  )
}
#' @export
ml_random_forest_regressor.pyspark_connection <- ml_random_forest_regressor_impl
#' @export
ml_random_forest_regressor.ml_connect_pipeline <- ml_random_forest_regressor_impl
#' @export
ml_random_forest_regressor.tbl_pyspark <- ml_random_forest_regressor_impl
#' @export

# ----------------------- Decision Tree Classifier  ----------------------------
ml_decision_tree_classifier_impl <- function(
    x, formula = NULL, max_depth = 5, max_bins = 32, min_instances_per_node = 1,
    min_info_gain = 0, impurity = "gini", seed = NULL, thresholds = NULL,
    cache_node_ids = FALSE, checkpoint_interval = 10, max_memory_in_mb = NULL,
    features_col = "features", label_col = "label", prediction_col = "prediction",
    probability_col = "probability", raw_prediction_col = "rawPrediction",
    uid = NULL, ...) {
  ml_process_fn(
    args = c(as.list(environment()), list(...)),
    fn = "DecisionTreeClassifier",
    has_fit = TRUE,
    ml_type = "classification",
    ml_fn = "decision_tree_classifier"
  )
}
#' @export
ml_decision_tree_classifier.pyspark_connection <- ml_decision_tree_classifier_impl
#' @export
ml_decision_tree_classifier.ml_connect_pipeline <- ml_decision_tree_classifier_impl
#' @export
ml_decision_tree_classifier.tbl_pyspark <- ml_decision_tree_classifier_impl
