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

py_check_installed <- function(
    envname = NULL,
    libraries = "",
    msg = "") {
  installed_libraries <- py_list_packages(envname = envname)$package
  find_libs <- map_lgl(libraries, ~ .x %in% installed_libraries)
  if (!all(find_libs)) {
    cli_div(theme = cli_colors())
    if (check_interactive()) {
      missing_lib <- libraries[!find_libs]
      cli_alert_warning(msg)
      cli_bullets(c(
        " " = "{.header Could not find: {missing_lib}}",
        " " = "Do you wish to install? {.class (This will be a one time operation)}"
      ))
      choice <- menu(choices = c("Yes", "Cancel"))
      if (choice == 1) {
        py_install(missing_lib)
      }
      if (choice == 2) {
        stop_quietly()
      }
    } else {
      cli_abort(msg)
    }
    cli_end()
  }
}

stop_quietly <- function() {
  opt <- options(show.error.messages = FALSE)
  on.exit(options(opt))
  stop()
}
