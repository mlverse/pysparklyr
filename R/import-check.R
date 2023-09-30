import_check <- function(x, envname) {
  env_found <- !is.na(envname)
  env_loaded <- NA

  if (py_available()) {
    # If there is a Python environment already loaded
    if (env_found) {
      if (env_python(envname) == py_exe()) {
        env_loaded <- TRUE
      } else {
        env_loaded <- FALSE
      }
    }
  } else {
    # If there is NO Python environment already loaded
    if (env_found) {
      # If the envname is found, we try to use it
      if (env_type(envname) == "virtualenv") {
        try(use_virtualenv(envname), silent = TRUE)
      } else {
        try(use_condaenv(envname), silent = TRUE)
      }
    }
  }

  out <- try(import(x), silent = TRUE)

  if (is.na(env_loaded)) {
    env_loaded <- env_python(envname) == py_exe()
  }

  inst <- NULL

  if (substr(envname, 1, 22) == "r-sparklyr-databricks-") {
    inst <- paste0(
      " {.run pysparklyr::install_databricks(",
      "envname = \"{envname}\")}"
    )
  }

  if (substr(envname, 1, 19) == "r-sparklyr-pyspark-") {
    inst <- paste0(
      " {.run pysparklyr::install_pyspark(",
      "envname = \"{envname}\")}"
    )
  }

  msg_install <- NULL
  msg_restart <- NULL
  if (!is.null(inst)) {
    # msg_install <- paste("{.header - Use} ", inst, "{.header to install.}")
    # msg_restart <- paste("- Restart your R session, and run:", inst)
  }

  if (inherits(out, "try-error")) {
    cli_alert_danger(glue("`reticulate` error:\n {out[[1]]}"))
    if (env_found) {
      if (env_loaded) {
        # found & loaded
        cli_abort(c(
          paste(
            "{.emph '{x}' }{.header is not available in the }",
            "{.emph '{envname}' }{.header Python environment.}"
          ),
          msg_install
        ), call = NULL)
      } else {
        cli_abort(c(
          "{.emph '{x}' }{.header is not available current Python environment.}",
          paste(
            "{.header - The }{.emph '{envname}'} {.header Python",
            " environment is installed, but it is not loaded.}"
          ),
          paste(
            "{.header - Restart your R session, and avoid",
            " initializing Python before using} {.emph '{x}'}"
          )
        ), call = NULL)
      }
    } else {
      cli_abort(c(
        "{.emph '{x}' }{.header is not available current Python environment.}",
        paste("- The {.emph '{envname}'} Python environment is not installed."),
        msg_restart
      ), call = NULL)
    }
  } else {
    if (env_loaded) {
      msg <- paste(
        "{.header Using the }{.emph '{envname}' }{.header Python}",
        "{.header environment }{.class ({py_exe()})}"
      )
      cli_div(theme = cli_colors())
      cli_alert_success(msg)
      cli_end()
    } else {
      msg <- paste(
        "{.header Not using the} {.emph '{envname}'} ",
        "{.header Python environment}.\n",
        "{.header - Current Python path:} {.emph {py_exe()}}"
      )
      cli_div(theme = cli_colors())
      cli_alert_warning(msg)
      cli_end()
    }
  }

  out
}

env_type <- function(envname) {
  ret <- NA
  if (virtualenv_exists(envname)) {
    ret <- "virtualenv"
  }
  if (is.na(ret)) {
    check_conda <- try(conda_python(envname), silent = TRUE)
    if (!inherits(check_conda, "try-error")) {
      ret <- "conda"
    }
  }
  ret
}

env_python <- function(envname) {
  ret <- NA
  type <- env_type(envname)
  if (!is.na(type)) {
    if (type == "virtualenv") {
      ret <- virtualenv_python(envname)
    }
    if (type == "conda") {
      ret <- conda_python(envname)
    }
  }
  ret
}
