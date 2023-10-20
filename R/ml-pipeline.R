#' @export
ml_pipeline.pyspark_connection <- function(x, ..., uid = NULL) {
  connect_pipeline <- import("pyspark.ml.connect.pipeline")
  jobj <- as_spark_pyobj(connect_pipeline, x)
  as_pipeline(jobj)
}

#' @export
ml_fit.ml_connect_pipeline <- function(x, dataset, ...) {
  py_sdf <- python_sdf(dataset)

  fitted <- try(
    x$.jobj$fit(py_sdf),
    silent = TRUE
  )

  if (inherits(fitted, "try-error")) {
    py_error <- reticulate::py_last_error()
    rlang::abort(
      paste(connection_label(x), "error:"),
      body = fitted
    )
  }

  stages <- map(fitted$stages, ml_print_params)

  jobj <- as_spark_pyobj(fitted, spark_connection(dataset))

  structure(
    list(
      uid = invoke(jobj, "uid"),
      param_map = list(),
      stages = stages,
      .jobj = jobj
    ),
    class = c(
      "ml_connect_pipeline_model",
      "ml_pipeline_model",
      "ml_transformer",
      "ml_connect_transformer",
      "ml_connect_pipeline_stage",
      "ml_pipeline_stage"
    )
  )
}

#' @export
ml_transform.ml_connect_pipeline_model <- function(x, dataset, ...) {
  transform_impl(x, dataset, prep = FALSE, remove = TRUE)
}

ml_print_params <-  function(x) {
  class_1 <- ml_get_last_item(class(x)[[1]])
  class_2 <- ml_get_last_item(class(x)[[3]])
  x_params <- x$params %>%
    map_chr(~ {
      nm <- .x$name
      nm <- paste0(toupper(substr(nm, 1, 1)), substr(nm, 2, nchar(nm)))
      fn <- paste0("get", nm)
      tr <- try(x[fn](), silent = TRUE)
      if(inherits(tr, "try-error")) {
        tr <- ""
      } else {
        tr <- glue("{.x$name}: {tr}")
      }
      tr
    })
  x_params <- x_params[x_params != ""]
  name_label <- paste0("<", capture.output(x), ">")
  ret <- paste0(x_params, collapse = "\n")
  ret <- paste0(
    class_1, " (", class_2, ")", "\n",
    name_label, "\n",
    "(Parameters)\n",
    ret
  )
  class(ret) <- "ml_output_params"
  ret
}

#' @export
print.ml_output_params <- function(x,...) {
  cat(x)
}

ml_connect_add_stage <- function(x, stage) {
  pipeline <- x$.jobj$pyspark_obj$Pipeline
  stage_print <- ml_print_params(stage)
  if(inherits(pipeline, "pyspark.ml.connect.pipeline.Pipeline")) {
    stages <- pipeline$getStages()
    outputs <- c(x$stages, list(stage_print))
    jobj <- pipeline(stages = c(stages, stage))
  } else {
    outputs <- list(stage_print)
    jobj <- pipeline(stages = c(stage))
  }
  as_pipeline(jobj, outputs, TRUE)
}

as_pipeline <- function(jobj, outputs = NULL, get_uid = FALSE) {
  if(get_uid) {
    uid <- invoke(jobj, "uid")
  }else {
    uid <- "[Not initialized]"
  }
  structure(
    list(
      uid = uid,
      param_map = list,
      stages = outputs,
      .jobj = jobj
    ),
    class = c(
      "ml_connect_pipeline",
      "ml_pipeline",
      "ml_connect_estimator",
      "ml_estimator",
      "ml_connect_pipeline_stage",
      "ml_pipeline_stage"
      )
  )
}

#' @importFrom sparklyr ml_save ml_load spark_jobj
#' @importFrom fs path_abs
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

#TODO: export ml_load() in sparklyr as S3 method
ml_connect_load <- function(sc, path) {
  path <- path_abs(path)
  conn <- python_obj_get(sc)
  connect_pipeline <- import("pyspark.ml.connect.pipeline")
  pipeline <- connect_pipeline$Pipeline$loadFromLocal(path)
  class_pipeline <- class(pipeline)
  class_current <- ml_get_last_item(class_pipeline[[1]])
  if(class_current == "Pipeline") {
    outputs <- map(pipeline$getStages(), ml_print_params)
    ret <- as_pipeline(pipeline, outputs, get_uid = TRUE)
  }
  ret
}
