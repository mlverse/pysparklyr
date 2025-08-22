#' @export
ft_r_formula.pyspark_connection <- function(x, formula = NULL,
                                            features_col = "features",
                                            label_col = "label",
                                            force_index_label = FALSE,
                                            uid = NULL, ...) {
  args <- c(as.list(environment()), list(...))
  ft_r_formula_prep(x, args, "RFormula")
}

#' @export
ft_r_formula.ml_connect_pipeline <- function(x, formula = NULL,
                                             features_col = "features",
                                             label_col = "label",
                                             force_index_label = FALSE,
                                             uid = NULL, ...) {
  args <- c(as.list(environment()), list(...))
  model <- ft_r_formula_prep(x, args, "RFormula")
  ml_connect_add_stage(
    x = x,
    stage = model
  )
}

#' @export
ft_r_formula.tbl_pyspark <- function(x, formula = NULL,
                                     features_col = "features",
                                     label_col = "label",
                                     force_index_label = FALSE,
                                     uid = NULL, ...) {
  args <- c(as.list(environment()), list(...))
  model <- ft_r_formula_prep(x, args, "RFormula")

  fitted <- ml_fit_impl(model, x)

  conn <- spark_connection(x)

  ret <- transform_impl(
    x = fitted,
    dataset = x,
    prep = FALSE,
    remove = FALSE,
    conn = conn,
    as_df = FALSE
  )

  tbl_pyspark_temp(ret, conn)
}


ft_r_formula_prep <- function(x, args, fn) {
  ml_installed()
  sc <- spark_connection(x)
  python_library <- "pyspark.ml.feature"
  args$zzz_formula <- args$formula
  jobj <- ml_execute(
    args = args,
    python_library = python_library,
    fn = fn,
    sc = sc
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
