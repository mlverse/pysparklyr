ml_process_fn <- function(args, fn, has_fit = TRUE, ml_type = "", ml_fn = NULL) {
  ml_installed()
  x <- args$x
  args <- args[names(args) != "x"]
  jobj <- ml_execute(
    args = args[names(args) != "formula"],
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
    glue("ml_{ml_fn}"),
    "ml_connect_estimator",
    "ml_estimator",
    "ml_pipeline_stage"
  )
  stage <- structure(
    prep_obj,
    class = obj_class
  )
  if (inherits(x, "pyspark_connection")) {
    return(stage)
  }
  if (inherits(x, "ml_connect_pipeline")) {
    return(ml_connect_add_stage(x, stage))
  }
  if (inherits(x, "tbl_pyspark")) {
    tbl_prep <- ml_prep_dataset(
      x = x,
      formula = args[["formula"]],
      label_col = args[["label_col"]],
      features_col = args[["features_col"]] %||% args[["raw_prediction_col"]],
      lf = "only",
      additional = args[["censor_col"]]
    )
    if (has_fit) {
      stage <- ml_fit_impl(stage, tbl_prep)
    }
    if (ml_type == "evaluation") {
      ret <- stage %>%
        invoke("evaluate", python_obj_get(x)) %>%
        python_obj_get() %>%
        py_to_r()

    } else {
      attrs <- attributes(tbl_prep)
      ret <- structure(
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
    return(ret)
  }
}

ml_process_transformer <- function(args, fn, has_fit = TRUE) {
  ml_installed()
  x <- args$x
  conn <- spark_connection(x)
  args <- args[names(args) != "x"]
  if (!is.null(args[["formula"]])) {
    if (rlang::is_formula(args[["formula"]])) {
      args[["formula"]] <- deparse(args[["formula"]])
    }
  }
  if (spark_version(conn) >= "4.0.0") {
    python_library <- "pyspark.ml.feature"
  } else {
    python_library <- "pyspark.ml.connect.feature"
  }
  jobj <- ml_execute(
    args = args,
    python_library = python_library,
    fn = fn,
    sc = conn
  )
  prep_obj <- list(
    uid = invoke(jobj, "uid"),
    param_map = ml_get_params(jobj),
    .jobj = jobj
  )
  obj_class <- "ml_pipeline_stage"
  stage <- structure(
    prep_obj,
    class = obj_class
  )
  if (inherits(x, "pyspark_connection")) {
    caller <- deparse(rlang::caller_call())
    ml_fn <- unlist(strsplit(caller, "\\."))[1]
    class(stage) <- c(ml_fn, "ml_transformer", class(stage))
    return(stage)
  }
  if (inherits(x, "ml_connect_pipeline")) {
    return(ml_connect_add_stage(x, stage))
  }
  if (inherits(x, "tbl_pyspark")) {
    tbl_prep <- ml_prep_dataset(
      x = x,
      label_col = args[["label_col"]],
      features_col = args[["input_col"]],
      lf = "all"
    )
    if (has_fit) {
      stage <- ml_fit_impl(stage, tbl_prep)
    }
    ret <- transform_impl(
      x = stage,
      dataset = tbl_prep,
      prep = FALSE,
      conn = conn,
      as_df = TRUE
    )
  }
  return(ret)
}
