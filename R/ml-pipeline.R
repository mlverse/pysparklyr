#' @export
ml_pipeline.pyspark_connection <- function(x, ..., uid = NULL) {
  ml_installed()
  if(spark_version(x) > "4.0") {
    ml <- import("pyspark.ml")
    jobj <- as_spark_pyobj(ml$Pipeline(), x)
  } else {
    connect_pipeline <- import("pyspark.ml.connect.pipeline")
    jobj <- as_spark_pyobj(connect_pipeline, x)
  }
  as_pipeline(jobj)
}

#' @export
ml_fit.ml_connect_pipeline <- function(x, dataset, ...) {
  fitted <- ml_fit_impl(x, dataset)
  stages <- map(invoke(fitted, "stages"), ml_print_params)
  as_pipeline_model(fitted, stages)
}

ml_fit_impl <- function(x, dataset) {
  ml_installed()
  py_dataset <- python_obj_get(dataset)
  py_x <- python_obj_get(x)

  fitted <- try(
    invoke(py_x, "fit", py_dataset),
    silent = TRUE
  )

  if (inherits(fitted, "try-error")) {
    py_error <- reticulate::py_last_error()
    rlang::abort(
      paste(connection_label(x), "error:"),
      body = fitted
    )
  }

  fitted
}


as_pipeline_model <- function(jobj, stages) {
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

ml_print_params <- function(x) {
  class_1 <- ml_get_last_item(class(x)[[1]])
  class_2 <- ml_get_last_item(class(x)[[3]])
  x_params <- x$params %>%
    map_chr(~ {
      nm <- .x$name
      nm <- paste0(toupper(substr(nm, 1, 1)), substr(nm, 2, nchar(nm)))
      fn <- paste0("get", nm)
      tr <- try(x[fn](), silent = TRUE)
      if (inherits(tr, "try-error")) {
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
print.ml_output_params <- function(x, ...) {
  cat(x)
}

ml_connect_add_stage <- function(x, stage) {
  pipeline_class <- "pyspark.ml.connect.pipeline.Pipeline"
  pipeline <- python_obj_get(x)
  if (!inherits(pipeline, pipeline_class)) {
    pipeline <- invoke(pipeline, "Pipeline")
  }
  stage_print <- ml_print_params(stage)
  if (inherits(pipeline, pipeline_class)) {
    # Not using invoke() here because it's returning a list
    # and we need a vector
    stages <- pipeline$getStages()
    outputs <- c(x$stages, list(stage_print))
    if (length(stages) > 0) {
      jobj <- invoke(pipeline, "setStages", c(stages, stage))
    } else {
      jobj <- invoke(pipeline, "stages", c(stages, stage))
    }
  } else {
    outputs <- list(stage_print)
    jobj <- pipeline(stages = c(stage))
  }
  as_pipeline(jobj, outputs, TRUE)
}

as_pipeline <- function(jobj, outputs = NULL, get_uid = FALSE) {
  if (get_uid) {
    uid <- invoke(jobj, "uid")
  } else {
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
