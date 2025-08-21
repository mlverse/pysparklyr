# ------------------------------- Standard Scaler ------------------------------

#' @export
ft_standard_scaler.pyspark_connection <- function(
    x, input_col = NULL, output_col = NULL,
    with_mean = NULL, with_std = NULL,
    uid = NULL,
    ...) {
  args <- c(as.list(environment()), list(...))
  ft_scaler_prep(x, args, "StandardScaler")
}

#' @export
ft_standard_scaler.ml_connect_pipeline <- function(
    x, input_col = NULL, output_col = NULL,
    with_mean = NULL, with_std = NULL,
    uid = NULL,
    ...) {
  args <- c(as.list(environment()), list(...))
  model <- ft_scaler_prep(x, args, "StandardScaler")
  ml_connect_add_stage(
    x = x,
    stage = python_obj_get(model)
  )
}

#' @export
ft_standard_scaler.tbl_pyspark <- function(
    x, input_col = NULL, output_col = NULL,
    with_mean = NULL, with_std = NULL,
    uid = NULL,
    ...) {
  ft_execute_scaler(
    x = x,
    input_col = input_col,
    output_col = output_col,
    .fn = "StandardScaler",
    ... = ...
  )
}

# ------------------------------- Max Abs Scaler -------------------------------

#' @export
ft_max_abs_scaler.pyspark_connection <- function(
    x, input_col = NULL, output_col = NULL,
    uid = NULL,
    ...) {
  args <- c(as.list(environment()), list(...))
  ft_scaler_prep(x, args, "MaxAbsScaler")
}

#' @export
ft_max_abs_scaler.ml_connect_pipeline <- function(
    x, input_col = NULL, output_col = NULL,
    uid = NULL,
    ...) {
  args <- c(as.list(environment()), list(...))
  model <- ft_scaler_prep(x, args, "MaxAbsScaler")
  ml_connect_add_stage(
    x = x,
    stage = python_obj_get(model)
  )
}

#' @export
ft_max_abs_scaler.tbl_pyspark <- function(
    x, input_col = NULL, output_col = NULL,
    uid = NULL,
    ...) {
  ft_execute_scaler(
    x = x,
    input_col = input_col,
    output_col = output_col,
    .fn = "MaxAbsScaler",
    ... = ...
  )
}

# ------------------------------- Implementation -------------------------------

ft_execute_scaler <- function(x, input_col = NULL, output_col = NULL, .fn = "", ...) {
  .input_col <- input_col
  .remove_input <- FALSE
  if (length(input_col) > 1) {
    .remove_input <- TRUE
    input_col <- random_string("ft_")
  }
  args <- c(as.list(environment()), list(...))

  model <- ft_scaler_prep(x, args, .fn)

  tbl_prep <- ml_prep_dataset(
    x = x,
    features = .input_col,
    features_col = input_col,
    lf = "all"
  )

  fitted <- ml_fit_impl(model, tbl_prep)

  conn <- spark_connection(x)

  ret <- transform_impl(
    x = fitted,
    dataset = tbl_prep,
    prep = FALSE,
    remove = FALSE,
    conn = conn,
    as_df = FALSE
  )
  if (.remove_input) {
    ret <- invoke(ret, "drop", input_col)
  }

  tbl_pyspark_temp(ret, conn)
}

ft_scaler_prep <- function(x, args, fn) {
  ml_installed()
  ml_connect_not_supported(
    args = args,
    not_supported = c(
      "with_mean", "with_std", "uid"
    )
  )

  if (spark_version(spark_connection(x)) >= "4.0.0") {
    python_library <- "pyspark.ml.feature"
  } else {
    python_library <- "pyspark.ml.connect.feature"
  }

  jobj <- ml_execute(
    args = args,
    python_library = python_library,
    fn = fn
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
