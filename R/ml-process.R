ml_process_fn <- function(args, fn, has_fit = TRUE, ml_type = "feature", ml_fn = NULL) {
  ml_installed()
  x <- args$x
  args <- args[names(args) != "x"]
  if (!is.null(args$formula)) {
    if (rlang::is_formula(args$formula)) {
      args$formula <- deparse(args$formula)
    }
  }
  jobj <- ml_execute(
    args = args,
    python_library = glue("pyspark.ml.{ml_type}"),
    fn = fn,
    sc = spark_connection(x)
  )
  args[["uid"]] <- invoke(jobj, "uid")
  prep_obj <- c(
    list(
      uid = invoke(jobj, "uid"),
      param_map = ml_get_params(jobj),
      .jobj = jobj
    )
  )
  obj_class <- c(
    "ml_connect_estimator",
    "ml_estimator",
    "ml_pipeline_stage"
  )
  if(ml_type != "feature") {
    obj_class <- c(obj_class, glue("ml_{ml_fn}"))
  }
  stage <- structure(
    prep_obj,
    class = obj_class
  )
  if (inherits(x, "pyspark_connection")) {
    class(stage) <- c("ml_transformer", class(stage))
    return(stage)
  }
  if (inherits(x, "ml_connect_pipeline")) {
    return(ml_connect_add_stage(x, stage))
  }
  if (inherits(x, "tbl_pyspark")) {
    return(ml_process_tbl(x, stage, args, has_fit, ml_type, ml_fn))
  }
  abort("Object not recognized")
}

ml_process_tbl <- function(x, stage, args, has_fit, ml_type = "feature", ml_fn) {
  formula <- NULL
  if(ml_type != "feature") {
    formula <- args$fomula
  }
  tbl_prep <- ml_prep_dataset(
    x = x,
    formula = formula,
    label_col = args$label_col,
    features_col = args$input_col %||% args$features_col,
    lf = "all"
  )
  if (has_fit) {
    stage <- ml_fit_impl(stage, tbl_prep)
  }

  if(ml_type == "feature") {
    conn <- spark_connection(x)
    ret <- transform_impl(
      x = stage,
      dataset = tbl_prep,
      prep = FALSE,
      remove = FALSE,
      conn = conn,
      as_df = FALSE
    )
    ret <- tbl_pyspark_temp(ret, conn)
  } else {
    attrs <- attributes(tbl_prep)
    structure(
      list(
        pipeline = stage,
        features = attrs$features,
        label = attrs$label
      ),
      class = c(
        "ml_connect_model",
        glue("ml_model_{ml_fn}"),
        glue("ml_model_{ml_type}"),
        "ml_model_prediction",
        "ml_model"
      )
    )
  }

  ret
}
