#' @export
ml_pipeline.pyspark_connection <- function(x, ..., uid = NULL) {
  ml_installed()
  if (spark_version(x) > "4.0") {
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
  sc <- spark_connection(x)
  stages <- map(invoke(fitted, "stages"), ml_print_params, sc)
  as_pipeline_model(fitted, stages)
}

ml_fit_impl <- function(x, dataset) {
  ml_installed()
  py_dataset <- python_obj_get(dataset)
  py_x <- get_spark_pyobj(x)

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

ml_print_params <- function(x, sc = NULL) {
  py_x <- python_obj_get(x)
  if (is.null(sc)) {
    x_params <- x$param_map
  } else {
    x_params <- x %>%
      as_spark_pyobj(sc) %>%
      ml_get_params()
  }
  x_params <- x_params |>
    map_chr(paste, collapse = ", ") %>%
    purrr::imap_chr(function(x, y) glue("{y}: {x}")) %>%
    paste0(collapse = "\n")
  name_label <- paste0("<", capture.output(py_x), ">")
  class_1 <- ml_get_last_item(class(py_x)[[1]])
  class_2 <- ml_get_last_item(class(py_x)[[3]])
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

ml_print_params1 <- function(x, sc) {
  class_1 <- ml_get_last_item(class(x)[[1]])
  class_2 <- ml_get_last_item(class(x)[[3]])
  x_params <- x %>%
    as_spark_pyobj(sc) %>%
    ml_get_params() %>%
    map_chr(paste, collapse = ", ") %>%
    purrr::imap_chr(function(x, y) glue("{y}: {x}")) %>%
    paste0(collapse = "\n")
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
  stages <- c(x$param_map, list(stage))
  py_stages <- NULL
  for (i in stages) {
    py_stages <- c(py_stages, python_obj_get(i))
  }
  pipeline <- x %>%
    get_spark_pyobj() %>%
    invoke("setStages", py_stages)
  outputs <- c(x$stages, list(ml_print_params(stage)))
  as_pipeline(pipeline, stages, outputs, TRUE)
}

ml_connect_add_stage1 <- function(x, stage) {
  pipeline <- get_spark_pyobj(x)
  pipeline_py <- python_obj_get(pipeline)
  stage <- stage %>%
    get_spark_pyobj() %>%
    python_obj_get()
  sc <- spark_connection(x)
  spark_new <- spark_version(sc) >= "4.0"
  loaded_pipeline_old <- inherits(pipeline_py, "pyspark.ml.connect.pipeline.Pipeline")
  if (!spark_new && !loaded_pipeline_old) {
    pipeline <- invoke(pipeline, "Pipeline")
  }
  loaded_pipeline_new <- FALSE
  if (inherits(pipeline_py, "pyspark.ml.pipeline.Pipeline")) {
    loaded_pipeline_new <- invoke(pipeline_py, "isSet", "stages")
  }
  loaded_pipeline <- loaded_pipeline_old | loaded_pipeline_new
  stage_print <- ml_print_params(stage, sc)
  if (loaded_pipeline) {
    # Not using invoke() here because it's returning a list
    # and we need a vector
    stages <- pipeline_py$getStages()
    outputs <- c(x$stages, list(stage_print))
    if (length(stages) > 0) {
      jobj <- invoke_simple(x, "setStages", c(stages, stage))
    } else {
      jobj <- invoke_simple(x, "stages", c(stages, stage))
    }
  } else {
    outputs <- list(stage_print)
    if (spark_new) {
      jobj <- invoke_simple(x, "setStages", c(stage))
    } else {
      jobj <- pipeline(stages = c(stage))
      jobj <- as_spark_pyobj(jobj, sc)
    }
  }
  as_pipeline(jobj, outputs, TRUE)
}

as_pipeline <- function(jobj, stages = list(), outputs = list(), get_uid = FALSE) {
  if (get_uid) {
    uid <- invoke(jobj, "uid")
  } else {
    uid <- "[Not initialized]"
  }
  structure(
    list(
      uid = uid,
      param_map = stages,
      .jobj = jobj,
      stages = outputs
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
