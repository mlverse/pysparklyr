#' @export
ml_linear_regression.tbl_pyspark <- function(x, formula = NULL, fit_intercept = TRUE,
                                             elastic_net_param = 0, reg_param = 0,
                                             max_iter = 100, weight_col = NULL,
                                             loss = "squaredError", solver = "auto",
                                             standardization = TRUE, tol = 1e-6,
                                             features_col = "features", label_col = "label",
                                             prediction_col = "prediction",
                                             uid = NULL, ...) {
  args <- c(as.list(environment()), list(...))

  prep_reg <- ml_linear_regression_prep(args)

  tbl_prep <- ml_prep_dataset(
    x = x,
    formula = formula,
    label_col = label_col,
    features_col = features_col,
    lf = "only"
  )

  fitted <- ml_fit_impl(prep_reg, tbl_prep)

  attrs <- attributes(tbl_prep)

  structure(
    list(
      pipeline = fitted,
      features = attrs$features,
      label = attrs$label
    ),
    class = c(
      "ml_connect_model",
      "ml_model_linear_regression",
      "ml_model_regression",
      "ml_model_prediction",
      "ml_model"
    )
  )
}

#' @export
ml_linear_regression.ml_connect_pipeline <- function(x, formula = NULL, fit_intercept = TRUE,
                                                     elastic_net_param = 0, reg_param = 0,
                                                     max_iter = 100, weight_col = NULL,
                                                     loss = "squaredError", solver = "auto",
                                                     standardization = TRUE, tol = 1e-6,
                                                     features_col = "features", label_col = "label",
                                                     prediction_col = "prediction",
                                                     uid = NULL, ...) {
  args <- c(as.list(environment()), list(...))
  model <- ml_linear_regression_prep(args)
  ml_connect_add_stage(
    x = x,
    stage = python_obj_get(model)
  )
}

#' @export
ml_linear_regression.pyspark_connection <- function(x, formula = NULL, fit_intercept = TRUE,
                                                    elastic_net_param = 0, reg_param = 0,
                                                    max_iter = 100, weight_col = NULL,
                                                    loss = "squaredError", solver = "auto",
                                                    standardization = TRUE, tol = 1e-6,
                                                    features_col = "features", label_col = "label",
                                                    prediction_col = "prediction",
                                                    uid = NULL, ...) {
  args <- c(as.list(environment()), list(...))
  ml_linear_regression_prep(args)
}

ml_linear_regression_prep <- function(args) {
  jobj <- ml_execute(
    args = args,
    python_library = "pyspark.ml.regression",
    fn = "LinearRegression",
    sc = spark_connection(x)
  )

  prep_reg <- structure(
    list(
      uid = invoke(jobj, "uid"),
      features_col = invoke(jobj, "getFeaturesCol"),
      label_col = invoke(jobj, "getLabelCol"),
      prediction_col = invoke(jobj, "getPredictionCol"),
      raw_prediction_col = invoke(jobj, "getPredictionCol"),
      probability_col = NULL,
      thresholds = NULL,
      param_map = list(),
      .jobj = jobj
    ),
    class = c(
      "ml_connect_estimator",
      "ml_linear_regression",
      "ml_probabilistic_classifier", # TODO: MAY NEED TO BE DIFFERENT
      "ml_classifier", # TODO: MAY NEED TO BE DIFFERENT
      "ml_predictor",
      "ml_estimator",
      "ml_pipeline_stage"
    )
  )
}

#' @export
ml_title.ml_model_linear_regression <- function(x) {
  "Linear Regression"
}
