import_check <- function(x, envname, silent = FALSE) {
  cli_div(theme = cli_colors())
  if (!silent) {
    cli_progress_step(
      msg = "Attempting to load {.emph '{envname}'}",
      msg_done = "{.header Python environment:} {.emph '{envname}'}",
      msg_failed = "Problem using {.emph '{envname}'}"
    )
  }
  env_found <- !is.na(envname)
  env_loaded <- NA
  look_for_env <- TRUE

  if (file.exists(envname)) {
    env_is_file <- TRUE
    env_path <- envname
  } else {
    env_is_file <- FALSE
    env_path <- env_python(envname)
  }

  if (env_is_file) {
    look_for_env <- FALSE
    use_python(envname)
    env_loaded <- TRUE
  }

  if (look_for_env) {
    if (py_available()) {
      # If there is a Python environment already loaded
      if (env_found) {
        find_env <- env_python(envname)
        if (is.na(find_env)) {
          find_env <- ""
        }
        if (find_env == py_exe()) {
          env_loaded <- TRUE
        } else {
          env_loaded <- FALSE
        }
      }
    } else {
      # If there is NO Python environment already loaded
      if (env_found) {
        # If the envname is found, we try to use it
        envir_type <- env_type(envname)
        if (is.na(envir_type)) {
          envir_type <- ""
        }
        if (envir_type == "virtualenv") {
          try(use_virtualenv(envname), silent = TRUE)
        } else {
          try(use_condaenv(envname), silent = TRUE)
        }
      }
    }
  }

  if (is.na(env_loaded)) {
    env_loaded <- env_path == py_exe()
  }

  out <- try(import(x), silent = TRUE)

  if (inherits(out, "try-error")) {
    if (env_found) {
      if (env_loaded) {
        # found & loaded
        rlang::abort(
          paste0(
            "Issue loading Python library '", x, "'\n",
            as.character(out)
          ),
          call = NULL
        )
      } else {
        cli_progress_done(result = "failed")
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
        paste("- The {.emph '{envname}'} Python environment is not installed.")
      ), call = NULL)
    }
    cli_alert_danger(glue("`reticulate` error:\n {out[[1]]}"))
  } else {
    if (env_loaded) {
      # if (look_for_env) {
      #   msg <- paste(
      #     "{.header Using the }{.emph '{envname}' }{.header Python}",
      #     "{.header environment }"
      #   )
      #   cli_div(theme = cli_colors())
      #   cli_alert_success(msg)
      #   cli_bullets(c(" " = "{.class Path: {py_exe()}}"))
      #   cli_end()
      # }
    } else {
      cli_progress_done(result = "failed")
      cli_bullets(c(
        " " = "{.header A different Python is already loaded: }{.emph '{py_exe()}'}",
        " " = "{.emph '{x}'} {.header was found and loaded from that environment}"
      ))
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
