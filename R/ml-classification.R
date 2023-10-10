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

  ml_connect_not_supported(
    args = args,
    not_supported = c("elastic_net_param", "reg_param", "threshold",
                      "aggregation_depth", "fit_intercept",
                      "raw_prediction_col", "uid")
    )

  pyspark <- import("pyspark")
  connect_classification <- import("pyspark.ml.connect.classification")

  if (!is.null(formula)) {
    f <- ml_formula(formula, x)
    features <- f$features
    label <- f$label
  } else {
    features <- features_col
    label <- label_col
  }

  features_array <- pyspark$sql$functions$array(features)

  x_df <- x[[1]]$session

  tbl_features <- x_df$withColumn("features", features_array)
  tbl_label <- tbl_features$withColumnRenamed(label, "label")
  tbl_prep <- tbl_label$select("label", "features")
  log_reg <- connect_classification$LogisticRegression()

  args$x <- NULL
  args$formula <- NULL

  args <- discard(args, is.null)

  new_names <- args %>%
    names() %>%
    map_chr(snake_to_camel)

  new_args <- set_names(args, new_names)

  prep_reg <- do.call(
    what = connect_classification$LogisticRegression,
    args = new_args
    )

  fitted <- prep_reg$fit(tbl_prep)
  fitted
}
