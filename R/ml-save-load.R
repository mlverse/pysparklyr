#' @export
ml_save.ml_connect_pipeline_stage <- function(x, path, overwrite = FALSE, ...) {
  path <- path_abs(path)
  invisible(
    x %>%
      spark_jobj() %>%
      invoke(
        method = "saveToLocal",
        path = path,
        overwrite = overwrite
      )
  )
}

# TODO: export ml_load() in sparklyr as S3 method
ml_connect_load <- function(sc, path) {
  path <- path_abs(path)
  conn <- python_obj_get(sc)
  connect_pipeline <- import("pyspark.ml.connect.pipeline")
  pipeline <- connect_pipeline$Pipeline$loadFromLocal(path)
  class_current <- ml_get_last_item(class(pipeline)[[1]])
  if (class_current == "Pipeline") {
    outputs <- map(pipeline$getStages(), ml_print_params)
    ret <- as_pipeline(pipeline, outputs, get_uid = TRUE)
  }
  if (class_current == "PipelineModel") {
    outputs <- map(pipeline$stages, ml_print_params)
    ret <- as_pipeline_model(pipeline, outputs)
  }
  ret
}
