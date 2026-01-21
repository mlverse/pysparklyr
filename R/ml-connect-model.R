# ------------------------- Prediction method ----------------------------------
#' @export
ml_predict.ml_connect_model <- function(x, dataset, ...) {
  transform_impl(x, dataset, prep = TRUE, remove = TRUE)
}

ml_get_last_item <- function(x) {
  classes <- x |>
    strsplit("\\.") |>
    unlist()

  classes[length(classes)]
}

transform_impl <- function(
  x,
  dataset,
  prep = TRUE,
  remove = FALSE,
  conn = NULL,
  as_df = TRUE
) {
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

  ret <- x |>
    get_spark_pyobj() |>
    invoke("transform", ml_df)

  if (remove) {
    if (inherits(x, "ml_connect_model")) {
      if (invoke(x, "hasParam", "labelCol")) {
        label_col <- invoke(x, "getLabelCol")
        ret <- invoke(ret, "drop", label_col)
      }
      features_col <- invoke(x, "getFeaturesCol")
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

# --------------------- Print method for the models ----------------------------

#' @export
print.ml_connect_model <- function(x, ...) {
  model_name <- unlist(strsplit(py_repr(python_obj_get(x)), ":"))[[1]]
  cli_h2("MLib model: {model_name}")
  print_coefficients(x)
  print_summary(x)
}

print_parameters <- function(x) {
  p <- get_params(x)
  p_descriptions <- p |>
    map_chr(\(.x) .x$description) |>
    as.character() |>
    strsplit("\\.") |>
    map(\(.x) .x[[1]])
  p_names <- map_chr(p, \(.x) .x$name)
  p_values <- p |>
    map(\(.x) {
      cl <- class(.x$value)
      .x$value
    }) |>
    as.character()
  p_values[nchar(p_values) >= 20] <- paste0(
    substr(p_values[nchar(p_values) >= 20], 1, 17),
    "..."
  )
  out <- paste0(
    cli::col_blue(cli::symbol$square_small_filled),
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
  two_col_print(out)
}

print_coefficients <- function(x) {
  py_x <- python_obj_get(x)
  coefs <- try(py_x[["coefficients"]], silent = TRUE)
  if (inherits(coefs, "try-error")) {
    return(invisible())
  }
  cli_h3("Coefficients:")
  coefs <- round(coefs["values"], 3)
  features <- x$features
  if (py_x$getFitIntercept()) {
    features <- c("Intercept", features)
    coefs <- c(round(py_x["intercept"], 3), coefs)
  }
  coefs <- as.character(coefs)
  coefs[coefs > 0] <- paste0(" ", coefs[coefs > 0])
  features <- paste0(features, ": ")

  out <- paste0(
    cli::col_blue(cli::symbol$square_small_filled),
    " ",
    cli::ansi_align(
      text = cli::col_silver(features),
      width = max(cli::ansi_nchar(features)) + 2
    ),
    cli::ansi_align(
      text = cli::col_silver(coefs),
      width = max(cli::ansi_nchar(coefs))
    )
  )
  two_col_print(out)
  cat("\n")
}

print_summary <- function(x) {
  py_x <- python_obj_get(x)
  has_summary <- try(py_x$hasSummary, silent = TRUE)
  if (inherits(has_summary, "try-error")) {
    has_summary <- FALSE
  }
  if (!has_summary) {
    print_parameters(x)
    return(invisible())
  }
  cli_h3("Summary:")
  py_x <- python_obj_get(x)
  summary_names <- names(py_x$summary)
  summary_values <- map(summary_names, function(x) py_x$summary[[x]])
  summary_valid <- summary_values |>
    map_lgl(function(x) inherits(x, "numeric") | inherits(x, "character"))
  summary_names <- summary_names[summary_valid]
  summary_values <- summary_values[summary_valid]
  summary_values <- summary_values |>
    map(function(x) {
      if (is.numeric(x)) {
        x <- round(x, 3)
      }
      x <- paste(x, collapse = ", ")
      if (nchar(x) > 30) {
        x <- glue("{substr(x, 1, 27)}...")
      }
      x
    })
  summary_names <- glue("{summary_names}: ")
  out <- paste0(
    cli::col_blue(cli::symbol$square_small_filled),
    " ",
    cli::ansi_align(
      text = cli::col_silver(summary_names),
      width = max(cli::ansi_nchar(summary_names)) + 1
    ),
    cli::ansi_align(
      text = cli::col_silver(summary_values),
      width = max(cli::ansi_nchar(summary_values))
    ),
    "\n"
  )
  walk(out, cat)
}

two_col_print <- function(x) {
  p_length <- length(x)
  is_odd <- p_length / 2 != floor(p_length / 2)
  if (is_odd) {
    x <- c(x, "")
    p_length <- p_length + 1
  }

  # p_sel <- rep(c(TRUE, FALSE), p_length)
  p_sel <- rep(c(TRUE, FALSE), 1, each = (p_length / 2))

  p_left <- x[p_sel]
  p_left <- p_left[!is.na(p_left)]
  p_right <- x[!p_sel]
  p_right <- p_right[!is.na(p_right)]

  p_two <- paste0(p_left, "   ", p_right)

  cat(paste0(p_two, collapse = "\n"))
}


#' @export
spark_jobj.ml_connect_model <- function(x, ...) {
  x$pipeline
}
