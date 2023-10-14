#' @export
ml_pipeline.pyspark_connection <- function(x, ..., uid = NULL) {
  connect_pipeline <- import("pyspark.ml.connect.pipeline")
  jobj <- as_spark_pyobj(connect_pipeline, sc)
  as_pipeline(jobj, FALSE)
}

ml_torch_add_stage <- function(x, stage) {
  pipeline <- x$.jobj$pyspark_obj$Pipeline
  if(inherits(pipeline, "pyspark.ml.connect.pipeline.Pipeline")) {
    stages <- pipeline$getStages()
    ret <- pipeline(stages = c(stages, stage))
  } else {
    ret <- pipeline(stages = c(stage))
  }
  ret
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
    class = c(
      "ml_torch_pipeline", "ml_pipeline",
      "ml_torch_estimator", "ml_torch_pipeline_stage",
      "ml_pipeline_stage"
      )
  )
}
