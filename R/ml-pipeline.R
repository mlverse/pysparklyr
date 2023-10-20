#' @export
ml_pipeline.pyspark_connection <- function(x, ..., uid = NULL) {
  connect_pipeline <- import("pyspark.ml.connect.pipeline")
  jobj <- as_spark_pyobj(connect_pipeline, sc)
  as_pipeline(jobj)
}

ml_torch_add_stage <- function(x, stage) {
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
      "ml_torch_pipeline",
      "ml_pipeline",
      "ml_torch_estimator",
      "ml_estimator",
      "ml_torch_pipeline_stage",
      "ml_pipeline_stage"
      )
  )
}

ml_get_last_item <- function(x) {
  classes <- x %>%
    strsplit("\\.") %>%
    unlist()

  classes[length(classes)]
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

#' @export
ml_fit.ml_torch_pipeline <- function(x, dataset, ...) {
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
      "ml_torch_pipeline_model",
      "ml_pipeline_model",
      "ml_transformer",
      "ml_torch_transformer",
      "ml_torch_pipeline_stage",
      "ml_pipeline_stage"
    )
  )
}
