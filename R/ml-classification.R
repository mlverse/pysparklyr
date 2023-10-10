#' @export
ml_logistic_regression.tbl_pyspark <- function(
    x, formula = NULL, fit_intercept = TRUE,
    elastic_net_param = 0, reg_param = 0, max_iter = 100,
    threshold = 0.5, thresholds = NULL, tol = 1e-06,
    weight_col = NULL, aggregation_depth = 2,
    lower_bounds_on_coefficients = NULL, lower_bounds_on_intercepts = NULL,
    upper_bounds_on_coefficients = NULL, upper_bounds_on_intercepts = NULL,
    features_col = "features", label_col = "label", family = "auto",
    prediction_col = "prediction", probability_col = "probability",
    raw_prediction_col = "rawPrediction",
    uid = random_string("logistic_regression_"), ...) {

  pyspark <- import("pyspark")
  connect_classification <- import("pyspark.ml.connect.classification")

  if(!is.null(formula)) {
    f <- ml_formula(formula, x)
  }

  features_array <- pyspark$sql$functions$array(f$features)

  x_df <- x[[1]]$session

  tbl_features <-  x_df$withColumn("features", features_array)
  tbl_label <- tbl_features$withColumnRenamed (f$label, "label")
  tbl_prep <- tbl_label$select("label", "features")

  log_reg <- connect_classification$LogisticRegression()

  fitted <- log_reg$fit(tbl_prep)
  fitted
}
