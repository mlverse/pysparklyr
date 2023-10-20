#' @export
print.ml_connect_model <- function(x, ...) {
  pyobj <- x$pipeline$pyspark_obj
  msg <- ml_get_last_item(class(pyobj)[[1]])
  cli_div(theme = cli_colors())
  cli_inform("<{.header {msg}}>")
  cli_end()
}

#' @export
spark_jobj.ml_connect_model <- function(x, ...) {
  x$pipeline
}

#' @export
ml_predict.ml_connect_model <- function(x, dataset, ...) {
  transform_impl(x, dataset, prep = TRUE)
}

ml_get_last_item <- function(x) {
  classes <- x %>%
    strsplit("\\.") %>%
    unlist()

  classes[length(classes)]
}

transform_impl <- function(x, dataset, prep = TRUE, remove = FALSE) {
  if (prep) {
    ml_df <- ml_prep_dataset(
      x = dataset,
      label = x$label,
      features = x$features,
      lf = "all"
    )
    ml_df <- ml_df$df
  } else {
    ml_df <- python_sdf(dataset)
  }

  py_object <- python_obj_get(x)

  ret <- py_object$transform(ml_df)

  if (remove) {
    stages <- py_object$stages
    last_stage <- stages[[length(stages)]]
    features_col <- last_stage$getFeaturesCol()
    label_col <- last_stage$getLabelCol()
    ret <- ret$drop(label_col)
    ret <- ret$drop(features_col)
  }

  tbl_pyspark_temp(
    x = ret,
    conn = spark_connection(dataset)
  )
}
