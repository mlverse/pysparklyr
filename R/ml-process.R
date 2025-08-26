ml_process_fn <- function(args, fn, has_fit = TRUE) {
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
    python_library = "pyspark.ml.feature",
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
  stage <- structure(
    prep_obj,
    class = "ml_pipeline_stage"
  )
  if (inherits(x, "pyspark_connection")) {
    class(stage) <- c("ml_transformer", class(stage))
    return(stage)
  }
  if (inherits(x, "ml_connect_pipeline")) {
    return(ml_connect_add_stage(x, stage))
  }
  if (inherits(x, "tbl_pyspark")) {
    return(ml_process_tbl(x, stage, args$input_col, has_fit))
  }
  abort("Object not recognized")
}

ml_process_tbl <- function(x, stage, input_col, has_fit) {
  tbl_prep <- ml_prep_dataset(
    x = x,
    features_col = input_col,
    lf = "all"
  )
  if (has_fit) {
    stage <- ml_fit_impl(stage, tbl_prep)
  }
  conn <- spark_connection(x)
  ret <- transform_impl(
    x = stage,
    dataset = tbl_prep,
    prep = FALSE,
    remove = FALSE,
    conn = conn,
    as_df = FALSE
  )
  tbl_pyspark_temp(ret, conn)
}
