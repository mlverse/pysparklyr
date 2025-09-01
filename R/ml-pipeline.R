#' @export
ml_pipeline.pyspark_connection <- function(x, ..., uid = NULL) {
  ml_installed()
  if (spark_version(x) > "4.0") {
    ml <- import("pyspark.ml")
    pipeline <- ml$Pipeline()
  } else {
    pipeline <- import("pyspark.ml.connect.pipeline")
  }
  pipeline %>%
    as_spark_pyobj(x) %>%
    as_pipeline()
}

#' @export
ml_fit.ml_connect_pipeline <- function(x, dataset, ...) {
  fitted <- ml_fit_impl(x, dataset)
  sc <- spark_connection(x)
  stages <- map(invoke(fitted, "stages"), ml_print_params, sc)
  as_pipeline_model(fitted, stages)
}

#' @export
ml_fit.ml_connect_cross_validator <- function(x, dataset, ...) {
  fitted <- ml_fit_impl(x, dataset)
  x <- python_obj_get(fitted)
  metrics <- x$avgMetrics %>%
    purrr::map2(x$getEstimatorParamMaps(), function(x, y) c(list(score = x),y)) %>%
    purrr::map(dplyr::as_tibble) %>%
    purrr::list_rbind()
  metric_names <- metrics %>%
    colnames() %>%
    strsplit("__") %>%
    map(unlist) %>%
    map_chr(function(x) x[length(x)])
  colnames(metrics) <- metric_names
  structure(
    list(
      uid = invoke(fitted, "uid"),
      param_map = list(),
      .jobj = fitted,
      avg_metrics_df = metrics
    ),
    class = c(
      "ml_cross_validator_model"
    )
  )
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
  x_params <- x_params %>%
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
