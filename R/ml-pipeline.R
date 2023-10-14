#' @export
ml_pipeline <- function(x, ..., uid = NULL) {
  connect_pipeline <- import("pyspark.ml.connect.pipeline")
  jobj <- as_spark_pyobj(connect_pipeline, sc)
  as_pipeline(jobj, FALSE)
}

as_pipeline <- function(jobj, get_uid = TRUE) {
  if(get_uid) {
    uid <- invoke(jobj, "uid")
  }else {
    uid <- NULL
  }
  structure(
    list(
      uid = uid,
      param_map = list,
      .jobj = jobj
    ),
    class = c("ml_estimator", "ml_torch_pipeline_stage", "ml_pipeline_stage")
  )
}
