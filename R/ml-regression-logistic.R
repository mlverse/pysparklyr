#' @export
ml_logistic_regression.pyspark_connection <- function(
    x, formula = NULL, fit_intercept = NULL,
    elastic_net_param = NULL, reg_param = NULL, max_iter = 100,
    threshold = NULL, thresholds = NULL, tol = 1e-06,
    weight_col = NULL, aggregation_depth = NULL,
    lower_bounds_on_coefficients = NULL, lower_bounds_on_intercepts = NULL,
    upper_bounds_on_coefficients = NULL, upper_bounds_on_intercepts = NULL,
    features_col = "features", label_col = "label", family = NULL,
    prediction_col = "prediction", probability_col = "probability",
    raw_prediction_col = NULL, uid = NULL, ...) {
  args <- c(as.list(environment()), list(...))
  ml_logistic_regression_prep(x, args)
}

#' @export
ml_logistic_regression.ml_connect_pipeline <- function(
    x, formula = NULL, fit_intercept = NULL,
    elastic_net_param = NULL, reg_param = NULL, max_iter = 100,
    threshold = NULL, thresholds = NULL, tol = 1e-06,
    weight_col = NULL, aggregation_depth = NULL,
    lower_bounds_on_coefficients = NULL, lower_bounds_on_intercepts = NULL,
    upper_bounds_on_coefficients = NULL, upper_bounds_on_intercepts = NULL,
    features_col = "features", label_col = "label", family = NULL,
    prediction_col = "prediction", probability_col = "probability",
    raw_prediction_col = NULL, uid = NULL, ...) {
  args <- c(as.list(environment()), list(...))
  model <- ml_logistic_regression_prep(x, args)
  ml_connect_add_stage(
    x = x,
    stage = python_obj_get(model)
  )
}

#' @export
ml_logistic_regression.tbl_pyspark <- function(
    x, formula = NULL, fit_intercept = NULL,
    elastic_net_param = NULL, reg_param = NULL, max_iter = 100,
    threshold = NULL, thresholds = NULL, tol = 1e-06,
    weight_col = NULL, aggregation_depth = NULL,
    lower_bounds_on_coefficients = NULL, lower_bounds_on_intercepts = NULL,
    upper_bounds_on_coefficients = NULL, upper_bounds_on_intercepts = NULL,
    features_col = "features", label_col = "label", family = NULL,
    prediction_col = "prediction", probability_col = "probability",
    raw_prediction_col = NULL, uid = NULL, ...) {
  args <- c(as.list(environment()), list(...))

  prep_reg <- ml_logistic_regression_prep(x, args)

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
      "ml_model_logistic_regression",
      "ml_model_classification",
      "ml_model_prediction",
      "ml_model"
    )
  )
}

ml_logistic_regression_prep <- function(x, args) {
  ml_installed()
  sc <- spark_connection(x)
  if (spark_version(sc) >= "4.0.0") {
    python_library <- "pyspark.ml.classification"
  } else {
    ml_connect_not_supported(
      args = args,
      not_supported = c(
        "elastic_net_param", "reg_param", "threshold",
        "aggregation_depth", "fit_intercept",
        "raw_prediction_col", "uid", "weight_col"
      )
    )
    python_library <- "pyspark.ml.connect.classification"
  }

  jobj <- ml_execute(
    args = args,
    python_library = python_library,
    fn = "LogisticRegression",
    sc = sc
  )

  structure(
    list(
      uid = invoke(jobj, "uid"),
      features_col = invoke(jobj, "getFeaturesCol"),
      label_col = invoke(jobj, "getLabelCol"),
      prediction_col = invoke(jobj, "getPredictionCol"),
      raw_prediction_col = invoke(jobj, "getPredictionCol"),
      probability_col = invoke(jobj, "getProbabilityCol"),
      thresholds = NULL,
      param_map = list(),
      .jobj = jobj
    ),
    class = c(
      "ml_connect_estimator",
      "ml_logistic_regression",
      "ml_probabilistic_classifier",
      "ml_classifier",
      "ml_predictor",
      "ml_estimator",
      "ml_pipeline_stage"
    )
  )
}


#' @export
print.ml_connect_estimator <- function(x, ...) {
  pyobj <- python_obj_get(x)
  msg <- ml_get_last_item(class(pyobj)[[1]])
  cli_div(theme = cli_colors())
  cli_inform("<{.header {msg}}>")
  cli_end()
}

#' @export
ml_title.ml_model_logistic_regression <- function(x) {
  "Logistic Regression"
}
