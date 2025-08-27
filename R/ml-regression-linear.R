ml_linear_regression_impl <- function(x, formula = NULL, fit_intercept = TRUE,
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
