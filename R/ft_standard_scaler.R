#' @importFrom sparklyr ft_standard_scaler

#' @export
ft_standard_scaler.pyspark_connection <- function(
    x, input_col = NULL, output_col = NULL,
    with_mean = NULL, with_std = NULL,
    uid = NULL,
    ...) {
  args <- c(as.list(environment()), list(...))
  ft_standard_scaler_prep(x, args)
}

#' @export
ft_standard_scaler.ml_connect_pipeline <- function(
    x, input_col = NULL, output_col = NULL,
    with_mean = NULL, with_std = NULL,
    uid = NULL,
    ...) {
  args <- c(as.list(environment()), list(...))
  model <- ft_standard_scaler_prep(x, args)
  ml_connect_add_stage(
    x = x,
    stage = model$.jobj
  )
}

#' @export
ft_standard_scaler.tbl_pyspark <- function(
    x, input_col = NULL, output_col = NULL,
    with_mean = NULL, with_std = NULL,
    uid = NULL,
    ...) {

  args <- c(as.list(environment()), list(...))

  model <- ft_standard_scaler_prep(x, args)

  ft_name <- random_table_name("ft_")

  tbl_prep <- ml_prep_dataset(
    x = x,
    features = input_col,
    features_col = ft_name,
    lf = "only"
  )


}

ft_standard_scaler_prep <- function(x, args) {
  ml_connect_not_supported(
    args = args,
    not_supported = c(
      "with_mean", "with_std", "uid"
    )
  )

  jobj <- ml_execute(
    args = args,
    python_library =  "pyspark.ml.connect.feature",
    fn = "StandardScaler"
  )

  structure(
    list(
      uid = invoke(jobj, "uid"),
      thresholds = NULL,
      param_map = list(),
      .jobj = jobj
    ),
    class = c(
      "ml_connect_estimator",
      "ml_estimator",
      "ml_pipeline_stage"
    )
  )
}
