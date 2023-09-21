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
      if(env_type(envname) == "virtualenv") {
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

  inst <- paste0(
    " {.run pysparklyr::install_pyspark(",
    "envname = \"{envname}\")}"
  )

  if (inherits(out, "try-error")) {
    if (env_found) {
      if (env_loaded) {
        # found & loaded
        cli_abort(paste(
          "Python library '{x}' is not available in the '{envname}'",
          "virtual environment. Install all of the needed python libraries",
          "using:", inst
        ))
      } else {
        cli_abort(paste(
          "Python library '{x}' is not available. The '{envname}'",
          "virtual environment is installed, but it is not loaded.",
          "Restart your R session, and avoid initializing Python",
          "before using `pysparklyr`"
        ))
      }
    } else {
      cli_abort(paste(
        "Python library '{x}' not available. The '{envname}'",
        "virtual environment is not installed. Restart your R session,",
        "and run:", inst
      ))
    }
  } else {
    if (is.null(pysparklyr_env$vars$python_init)) {
      if (env_loaded) {
        msg <- paste(
          "Using the {.emph '{envname}'} virtual",
          "environment {.class ({py_exe()})}"
        )
        cli_div(theme = cli_colors())
        cli_alert_success(msg)
        cli_end()
      } else {
        msg <- paste(
          "Not using the '{envname}' virtual environment",
          "for python. The current path is: {py_exe()}"
        )
        cli_alert_danger(msg)
      }
      pysparklyr_env$vars$python_init <- 1
    }
  }

  out
}

env_type <- function(envname) {
  ret <- NA
  if(envname %in% virtualenv_list()) {
    ret <- "virtualenv"
  }
  if(envname %in% conda_list()$name && is.na(ret)) {
    ret <- "conda"
  }
  ret
}

env_python <- function(envname) {
  ret <- NA
  type <- env_type(envname)
  if(!is.na(type)) {
    if(type == "virtualenv") {
      ret <- virtualenv_python()
    }
    if(type == "conda") {
      ret <- conda_python()
    }
  }
  ret
}
