ml_binary_classification_evaluator_impl <- function(
    x, label_col = "label", raw_prediction_col = "rawPrediction",
    metric_name = "areaUnderROC", uid = NULL, ...) {
  ml_process_fn(
    args = c(as.list(environment()), list(...)),
    fn = "BinaryClassificationEvaluator",
    has_fit = FALSE,
    ml_type = "evaluation"
  )
}
#' @export
ml_binary_classification_evaluator.pyspark_connection <- ml_binary_classification_evaluator_impl
#' @export
ml_binary_classification_evaluator.tbl_pyspark <- ml_binary_classification_evaluator_impl

ml_multiclass_classification_evaluator_impl <- function(
    x, label_col = "label", prediction_col = "prediction",
    metric_name = "f1", uid = NULL, ...) {
  ml_process_fn(
    args = c(as.list(environment()), list(...)),
    fn = "MulticlassClassificationEvaluator",
    has_fit = FALSE,
    ml_type = "evaluation"
  )
}
#' @export
ml_multiclass_classification_evaluator.pyspark_connection <- ml_multiclass_classification_evaluator_impl
#' @export
ml_multiclass_classification_evaluator.tbl_pyspark <- ml_multiclass_classification_evaluator_impl

ml_clustering_evaluator_impl <- function(
    x, features_col = "features", prediction_col = "prediction",
    metric_name = "silhouette", uid = NULL, ...) {
  ml_process_fn(
    args = c(as.list(environment()), list(...)),
    fn = "ClusteringEvaluator",
    has_fit = FALSE,
    ml_type = "evaluation"
  )
}
#' @export
ml_clustering_evaluator.pyspark_connection <- ml_clustering_evaluator_impl
#' @export
ml_clustering_evaluator.tbl_pyspark <- ml_clustering_evaluator_impl

ml_regression_evaluator_impl <- function(
    x, label_col = "label", prediction_col = "prediction", metric_name = "rmse",
    uid = NULL, ...) {
  ml_process_fn(
    args = c(as.list(environment()), list(...)),
    fn = "RegressionEvaluator",
    has_fit = FALSE,
    ml_type = "evaluation"
  )
}
#' @export
ml_regression_evaluator.pyspark_connection <- ml_regression_evaluator_impl
#' @export
ml_regression_evaluator.tbl_pyspark <- ml_regression_evaluator_impl
