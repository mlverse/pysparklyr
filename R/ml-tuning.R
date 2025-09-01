#' @export
ml_cross_validator.pyspark_connection <- function(
    x, estimator = NULL, estimator_param_maps = NULL, evaluator = NULL,
    num_folds = 3, collect_sub_models = FALSE, parallelism = 1, seed = NULL,
    uid = NULL, ...) {
  if(!inherits(estimator, "ml_connect_pipeline")) {
    abort("Only ML Pipelines are supported at this time")
  }
  tuning <- import("pyspark.ml.tuning")
  pipeline <- python_obj_get(estimator)
  stages <- pipeline$getStages()
  stages_name <- stages %>%
    map_chr(py_repr) %>%
    tolower()
  grid <- tuning$ParamGridBuilder()
  map_names <- estimator_param_maps %>%
    names() %>%
    map_chr(snake_to_camel) %>%
    tolower()
  for (map_name in map_names) {
    stage_match <- startsWith(stages_name, map_name)
    if (sum(stage_match) == 1) {
      curr_stage <- stages[stage_match][[1]]
      curr_map <- estimator_param_maps[map_name == map_names][[1]]
      list_map <- imap(curr_map, function(x, y) list(name = y, values = x))
      for (param in list_map) {
        grid$addGrid(
          param = curr_stage[[snake_to_camel(param$name)]],
          values = param$values
        )
      }
    }
  }
  built_grid <- grid %>%
    as_spark_pyobj(x) %>%
    invoke("build")
  cv_estimator <- ml_process_fn(
    args = list(
      x = sc,
      estimator = python_obj_get(estimator),
      estimator_param_maps = python_obj_get(built_grid),
      evaluator = python_obj_get(evaluator),
      num_folds = num_folds,
      parallelism = parallelism,
      seed = seed,
      collect_sub_models = collect_sub_models
    ),
    fn = "CrossValidator",
    ml_type = "tuning",
    has_fit = TRUE
  )

  class(cv_estimator) <- c(
    "ml_connect_cross_validator", "ml_cross_validator", class(cv_estimator)
    )
  cv_estimator
}
