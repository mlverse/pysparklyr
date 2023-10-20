#' @importFrom sparklyr ft_standard_scaler
#' @export
ft_standard_scaler.ml_connect_pipeline <- function(
    x, input_col = NULL, output_col = NULL,
    with_mean = NULL, with_std = NULL,
    uid = NULL,
    ...
    ) {
  args <- c(as.list(environment()), list(...))
  model <- ft_standard_scaler_prep(x, args)
  ml_connect_add_stage(
    x = x,
    stage = model$.jobj
  )
}

ft_standard_scaler_prep <- function(x, args) {
  ml_connect_not_supported(
    args = args,
    not_supported = c(
      "with_mean", "with_std", "uid"
    )
  )

  connect_feature <- import("pyspark.ml.connect.feature")

  args$x <- NULL
  args$formula <- NULL

  args <- discard(args, is.null)

  new_names <- args %>%
    names() %>%
    map_chr(snake_to_camel)

  new_args <- set_names(args, new_names)

  invisible(
    jobj <- do.call(
      what = connect_feature$StandardScaler,
      args = new_args
    )
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
