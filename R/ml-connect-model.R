#' @export
print.ml_connect_model <- function(x, ...) {
  cli_h3("ML Connect model:")
  cat(cli::style_reset(ml_title(x)))
  cli_h3("Parameters:")
  print_parameters(x)
}

print_parameters <- function(x) {
  p <- get_params(x)
  p_descriptions <- p %>%
    map_chr(~ .x$description) %>%
    as.character() %>%
    strsplit("\\.") %>%
    map(~ .x[[1]])

  p_names <- map_chr(p, ~ .x$name)
  p_values <- p %>%
    map(~ {
      cl <- class(.x$value)
      out <- .x$value
      # if(cl == "character") out <- paste0("'", out, "'")
      out
    }) %>%
    as.character()
  p_bullet <- cli::col_blue(cli::symbol$square_small_filled)
  p_paste <- paste0(
    p_bullet,
    " ",
    cli::ansi_align(
      text = cli::style_hyperlink(paste0(p_names, ":"), p_descriptions),
      width = max(cli::ansi_nchar(p_names)) + 2
    ),
    cli::ansi_align(
      text = cli::col_silver(p_values),
      width = max(cli::ansi_nchar(p_values))
    )
  )
  p_length <- length(p_names)
  is_odd <- p_length / 2 != floor(p_length / 2)
  if (is_odd) {
    p_paste <- c(p_paste, "")
    p_length <- p_length + 1
  }

  # p_sel <- rep(c(TRUE, FALSE), p_length)
  p_sel <- rep(c(TRUE, FALSE), 1, each = (p_length / 2))

  p_left <- p_paste[p_sel]
  p_left <- p_left[!is.na(p_left)]
  p_right <- p_paste[!p_sel]
  p_right <- p_right[!is.na(p_right)]

  p_two <- paste0(p_left, "   ", p_right)

  cat(paste0(p_two, collapse = "\n"))
}

ml_title <- function(x) {
  UseMethod("ml_title")
}

#' @export
ml_title.ml_model_logistic_regression <- function(x) {
  "Logistic Regression"
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

transform_impl <- function(x, dataset, prep = TRUE,
                           remove = FALSE, conn = NULL,
                           as_df = TRUE) {
  ml_installed()
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
    if (inherits(x, "ml_connect_model")) {
      label_col <- invoke(x, "getLabelCol")
      features_col <- invoke(x, "getFeaturesCol")
      ret <- invoke(ret, "drop", label_col)
      ret <- invoke(ret, "drop", features_col)
    } else {
      stages <- invoke(py_object, "stages")
      for (i in stages) {
        if (invoke(i, "hasParam", "inputCol")) {
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

  if (is.null(conn)) {
    conn <- spark_connection(dataset)
  }
  if (as_df) {
    ret <- tbl_pyspark_temp(
      x = ret,
      conn = conn
    )
  }
  ret
}
