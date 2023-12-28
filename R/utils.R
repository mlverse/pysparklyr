#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr:pipe]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @usage lhs \%>\% rhs
#' @param lhs A value or the magrittr placeholder.
#' @param rhs A function call using the magrittr semantics.
#' @return The result of calling `rhs(lhs)`.
NULL

reticulate_python_check <- function(ignore = FALSE, unset = TRUE, message = TRUE) {
  if (ignore) {
    return("")
  }

  out <- ""

  env_var <- Sys.getenv("RETICULATE_PYTHON", unset = NA)

  if (current_product_connect() && !is.na(env_var)) {
    out <- env_var
  }

  if (!is.na(env_var) && out == "") {
    if (unset) {
      Sys.unsetenv("RETICULATE_PYTHON")
      if (message) {
        cli_div(theme = cli_colors())
        cli_alert_warning(paste0(
          "{.header Your }{.emph 'RETICULATE_PYTHON'}",
          " {.header environment variable was unset.}"
        ))
        cli_bullets(c(
          " " = "{.class To recover, restart R after you closing your Spark session}"
        ))
        cli_end()
      }
    } else {
      if (message) {
        cli_alert_warning(paste(
          paste0(
            "Your {.emph 'RETICULATE_PYTHON'} environment is set, ",
            "which may cause connectivity issues"
          ),
          paste0(
            "Use {.code Sys.unsetenv(\"RETICULATE_PYTHON\")} to clear for the",
            "duration of your current R session."
          ),
          sep = "\n"
        ))
      }
    }
  }
  out
}

check_arg_supported <- function(x, msg = NULL) {
  arg <- enquo(x)
  if (!is.null(x)) {
    if (is.null(msg)) {
      arg_name <- deparse(x)
      msg <- glue(
        paste(
          "The '{rlang::as_label(arg)}' argument is not currently",
          "supported for this back-end"
        )
      )
    }
    cli_abort(msg)
  }
  invisible()
}

cli_colors <- function(envir = parent.frame()) {
  list(
    span.header = list(color = "silver"),
    span.class = list(color = "darkgray"),
    span.info = list(),
    span.spark = list(color = "darkgray")
  )
}


current_product_connect <- function() {
  out <- FALSE
  if (Sys.getenv("RSTUDIO_PRODUCT") == "CONNECT") {
    out <- TRUE
  }
  out
}
