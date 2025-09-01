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
