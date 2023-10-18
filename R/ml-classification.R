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
ml_logistic_regression.ml_torch_pipeline <- function(
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
  ml_torch_add_stage(
    x = x,
    stage = model$.jobj
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

  fitted <- try(
    prep_reg$.jobj$fit(tbl_prep$df),
    silent = TRUE
    )

  if (inherits(fitted, "try-error")) {
    py_error <- reticulate::py_last_error()
    rlang::abort(
      paste(connection_label(x), "error:"),
      body = fitted
    )
  }

  as_torch_model(
    fitted, tbl_prep$features, tbl_prep$label, spark_connection(x)
    )
}

ml_prep_dataset <- function(
    x,
    formula = NULL,
    label = NULL,
    features = NULL,
    label_col = "label",
    features_col = "features",
    lf = c("only", "all")
    ) {
  lf <- match.arg(lf)

  pyspark <- x %>%
    spark_connection() %>%
    import_main_library()

  x_df <- x[[1]]$session

  if (!is.null(formula)) {
    f <- ml_formula(formula, x)
    features <- f$features
    label <- f$label
  } else {
    if(is.null(features)) {
      features <- features_col
    }
    if(is.null(label)) {
      label <- label_col
    }
  }

  features_array <- pyspark$sql$functions$array(features)
  tbl_features <- x_df$withColumn(features_col, features_array)
  tbl_label <- tbl_features$withColumn(label_col, tbl_features[label])

  if(lf == "only") {
    tbl_prep <- tbl_label$select(c(label_col, features_col))
  }

  if(lf == "all") {
    tbl_prep <- tbl_label
  }

  list(
    label = label,
    features = features,
    df = tbl_prep
  )

}

as_torch_model <- function(x, features, label, con) {
  structure(
    list(
      pipeline = as_spark_pyobj(x, con),
      features = features,
      label = label
    ),
    class = c(
      "ml_torch_model",
      "ml_model_logistic_regression",
      "ml_model_classification",
      "ml_model_prediction",
      "ml_model"
    )
  )
}

ml_logistic_regression_prep <- function(x, args) {
  ml_connect_not_supported(
    args = args,
    not_supported = c(
      "elastic_net_param", "reg_param", "threshold",
      "aggregation_depth", "fit_intercept",
      "raw_prediction_col", "uid", "weight_col"
    )
  )

  connect_classification <- import("pyspark.ml.connect.classification")

  log_reg <- connect_classification$LogisticRegression()

  args$x <- NULL
  args$formula <- NULL

  args <- discard(args, is.null)

  new_names <- args %>%
    names() %>%
    map_chr(snake_to_camel)

  new_args <- set_names(args, new_names)

  invisible(
    jobj <- do.call(
      what = connect_classification$LogisticRegression,
      args = new_args
    )
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
      "ml_torch_estimator",
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
print.ml_torch_model <- function(x, ...) {
  pyobj <- x$pipeline$pyspark_obj
  msg <- ml_get_last_item(class(pyobj)[[1]])
  cli_div(theme = cli_colors())
  cli_inform("<{.header {msg}}>")
  cli_end()
}

#' @export
ml_fit.ml_torch_pipeline <- function(x, dataset, ...) {
  dataset <- python_sdf(dataset)

  fitted <- try(
    x$.jobj$fit(dataset),
    silent = TRUE
  )

  if (inherits(fitted, "try-error")) {
    py_error <- reticulate::py_last_error()
    rlang::abort(
      paste(connection_label(x), "error:"),
      body = fitted
    )
  }

  fitted
}

#' @export
ml_predict.ml_torch_model <- function(x, dataset, ...) {
  transform_impl(x, dataset, prep = TRUE)
}

#' @export
ml_transform.ml_torch_model <- function(x, dataset, ...) {
  transform_impl(x, dataset, prep = FALSE)
}

transform_impl <- function(x, dataset, prep = TRUE) {
  if(prep) {
    ml_df <- ml_prep_dataset(
      x = dataset,
      label = x$label,
      features = x$features,
      lf = "all"
    )
    ml_df <- ml_df$df
  } else {
    ml_df <- python_sdf(dataset)
  }

  transformed <- x$pipeline$pyspark_obj$transform(ml_df)

  tbl_pyspark_temp(
    x = transformed,
    conn = spark_connection(dataset)
  )
}

#' @export
print.ml_torch_estimator <- function(x, ...) {
  pyobj <- x$.jobj
  msg <- ml_get_last_item(class(pyobj)[[1]])
  cli_div(theme = cli_colors())
  cli_inform("<{.header {msg}}>")
  cli_end()
}
