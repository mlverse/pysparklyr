ml_process_fn <- function(args, fn, has_fit = TRUE, ml_type = "feature", ml_fn = NULL) {
  ml_installed()
  x <- args$x
  args <- args[names(args) != "x"]
  if (ml_type == "feature") {
    if (!is.null(args[["formula"]])) {
      if (rlang::is_formula(args[["formula"]])) {
        args[["formula"]] <- deparse(args[["formula"]])
      }
    }
    exec_args <- args
  } else {
    exec_args <- args[names(args) != "formula"]
  }

  jobj <- ml_execute(
    args = exec_args,
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
  if (ml_type != "feature") {
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
    arg_formula <- NULL
    if (ml_type != "feature") {
      arg_formula <- args[["formula"]]
    }
    arg_label_col <- args[["label_col"]]
    arg_features_col <- args[["input_col"]] %||%
      args[["features_col"]] %||%
      args[["raw_prediction_col"]]
    new_obj <- ml_process_tbl(
      x = x,
      stage = stage,
      formula = arg_formula,
      label_col = arg_label_col,
      features_col = arg_features_col,
      has_fit = has_fit,
      ml_type = ml_type,
      ml_fn = ml_fn
    )
    return(new_obj)
  }
  abort("Object not recognized")
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
  jobj <- ml_execute(
    args = args,
    python_library = "pyspark.ml.feature",
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


ml_process_tbl <- function(x, stage, formula, label_col, features_col,
                           has_fit, ml_type = "feature", ml_fn) {
  tbl_prep <- ml_prep_dataset(
    x = x,
    formula = formula,
    label_col = label_col,
    features_col = features_col,
    lf = ifelse(ml_type == "feature", "all", "only")
  )
  if (has_fit) {
    stage <- ml_fit_impl(stage, tbl_prep)
  }

  if (ml_type == "feature") {
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
  } else if (ml_type == "evaluation") {
    # TODO: Output will probably need to be expanded to a tbl
    ret <- invoke(stage, "evaluate", python_obj_get(x))
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

  ret
}
