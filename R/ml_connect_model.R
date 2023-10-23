#' @export
print.ml_connect_model <- function(x, ...) {
  pyobj <- python_obj_get(x)
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
  transform_impl(x, dataset, prep = TRUE, remove = TRUE)
}

ml_get_last_item <- function(x) {
  classes <- x %>%
    strsplit("\\.") %>%
    unlist()

  classes[length(classes)]
}

transform_impl <- function(x, dataset, prep = TRUE, remove = FALSE, conn = NULL) {
  if (prep) {
    ml_df <- ml_prep_dataset(
      x = dataset,
      label = x$label,
      features = x$features,
      lf = "all"
    )
  } else {
    ml_df <- python_obj_get(dataset)
  }

  py_object <- python_obj_get(x)

  ret <- invoke(x, "transform", ml_df)

  if (remove) {
    if(inherits(x, "ml_connect_model")) {
      label_col <- invoke(x, "getLabelCol")
      features_col <- invoke(x, "getFeaturesCol")
      ret <- invoke(ret, "drop", label_col)
      ret <- invoke(ret, "drop", features_col)
    } else {
      stages <- invoke(py_object, "stages")
      for(i in stages) {
        if(invoke(i, "hasParam", "inputCol")) {
          input_col <- invoke(i, "getInputCol")
          ret <- invoke(ret, "drop", input_col)
        } else {
          label_col <- invoke(i, "getLabelCol")
          features_col <- invoke(i, "getFeaturesCol")
          ret <- invoke(ret, "drop", label_col)
          ret <- invoke(ret, "drop", features_col)
        }
      }
    }
  }

  if(is.null(conn)) {
    conn <- spark_connection(dataset)
  }
  tbl_pyspark_temp(
    x = ret,
    conn = conn
  )
}
