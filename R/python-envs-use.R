use_envname <- function(
    envname = NULL,
    method = "spark_connect",
    version = "1.1",
    messages = FALSE,
    match_first = FALSE,
    ignore_reticulate_python = FALSE) {

  if(!ignore_reticulate_python) {
    reticulate_python <- Sys.getenv("RETICULATE_PYTHON", unset = NA)
    if (!is.na(reticulate_python)) {
      if (messages) {
        msg <- c(
          "{.header Using the Python environment defined in the}",
          "{.emph 'RETICULATE_PYTHON' }{.header environment variable}",
          "{.class ({py_exe()})}"
        )
        cli_div(theme = cli_colors())
        cli_alert_warning(msg)
        cli_end()
      }
      envname <- reticulate_python
    }
  }

  if (is.null(envname)) {
    if (method == "spark_connect") {
      env_base <- "r-sparklyr-pyspark-"
      run_code <- glue(
        "pysparklyr::install_pyspark(version = \"{version}\")"
      )
    } else {
      env_base <- "r-sparklyr-databricks-"
      run_code <- glue(
        "pysparklyr::install_databricks(version = \"{version}\")"
      )
    }
    envs <- find_environments(env_base)
    if (length(envs) == 0) {
      if (messages) {
        cli_div(theme = cli_colors())
        cli_abort(
          c(
            "{.header No environment name provided, and no environment was automatically identified.}",
            "* {.header Run: {.run {run_code}} to install.}"
          )
        )
        cli_end()
      }
    } else {
      if (!is.null(version)) {
        sp_version <- version_prep(version)
        envname <- glue("{env_base}{sp_version}")
        matched <- envs[envs == envname]
        if (match_first) {
          if (length(matched) == 0) {
            envname <- envs[[1]]
            if (messages) {
              cli_div(theme = cli_colors())
              cli_alert_warning(paste(
                "{.header A Python environment with a matching version was not found}",
                "* {.header Will attempt connecting using }{.emph '{envname}'}",
                "* {.header To install the proper Python environment use: {.run {run_code}}}",
                sep = "\n"
              ))
              cli_end()
            }
          } else {
            envname <- matched
          }
        }
      } else {
        envname <- envs[[1]]
      }
    }
  }
  envname
}

find_environments <- function(x) {
  conda_names <- tryCatch(conda_list()$name, error = function(e) character())
  ve_names <- virtualenv_list()
  all_names <- c(ve_names, conda_names)
  sub_names <- substr(all_names, 1, nchar(x))
  matched <- all_names[sub_names == x]
  sorted <- sort(matched, decreasing = TRUE)
  sorted
}
