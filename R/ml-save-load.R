#' @export
ml_save.ml_connect_pipeline_stage <- function(x, path, overwrite = FALSE, ...) {
  ml_installed()
  path <- path_abs(path)

  py_obj <- get_spark_pyobj(x)

  version <- py_obj %>%
    spark_connection() %>%
    spark_version()

  if(version >= "4.0") {
    model <- python_obj_get(py_obj)
    model$save(path)
  } else {
    x %>%
      spark_jobj() %>%
      invoke(
        method = "saveToLocal",
        path = path,
        overwrite = overwrite
      )
  }
  return(invisible())
}

# TODO: export ml_load() in sparklyr as S3 method
ml_connect_load <- function(sc, path) {
  ml_installed()
  path <- path_abs(path)
  conn <- python_obj_get(sc)
  if(spark_version(sc) >= "4.0") {
    connect_pipeline <- import("pyspark.ml")
    pipeline <- connect_pipeline$Pipeline$load(path)
  } else {
    connect_pipeline <- import("pyspark.ml.connect.pipeline")
    pipeline <- connect_pipeline$Pipeline$loadFromLocal(path)
  }

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
