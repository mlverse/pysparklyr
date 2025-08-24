ft_binarizer_impl <- function(
    x,
    input_col = NULL,
    output_col = NULL,
    threshold = 0,
    uid = NULL, ...) {
  ml_process_fn(
    args = c(as.list(environment()), list(...)),
    fn = "Binarizer"
  )
}

# ----------- Methods -------------

#' @export
ft_binarizer.ml_connect_pipeline <- ft_binarizer_impl
#' @export
ft_binarizer.pyspark_connection <- ft_binarizer_impl
#' @export
ft_binarizer.tbl_pyspark <- ft_binarizer_impl


ml_process_fn <- function(args, fn) {
  ml_installed()
  x <- args$x
  args <- args[names(args) != "x"]
  sc <- spark_connection(x)
  python_library <- "pyspark.ml.feature"
  jobj <- ml_execute(
    args = args,
    python_library = python_library,
    fn = fn,
    sc = sc
  )
  args[["uid"]] <- invoke(jobj, "uid")
  prep_obj <- c(
    list(
      uid = invoke(jobj, "uid"),
      param_map = list(),
      .jobj = jobj
    ),
    args
  )
  stage <- structure(
    prep_obj,
    class = "ml_pipeline_stage"
  )
  if(inherits(x, "pyspark_connection")) {
    return(stage)
  }
  if(inherits(x, "ml_connect_pipeline")) {
    return(ml_connect_add_stage(x, stage))
  }
  abort("Object not recognized")
}
