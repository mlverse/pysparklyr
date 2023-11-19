use_envname <- function(
    envname = NULL,
    method = "spark_connect",
    version = "1.1",
    messages = FALSE,
    match_first = FALSE,
    ignore_reticulate_python = FALSE,
    ask_if_not_installed = TRUE
    ) {

  reticulate_python_check(ignore_reticulate_python)
  label <- "argument"
  if (is.null(envname)) {
    envname_null <- TRUE
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

    if(!is.null(version)) {
      label <- "unavailable"
      sp_version <- version_prep(version)
      envname <- glue("{env_base}{sp_version}")
    }

    envs <- find_environments(env_base)
    if (length(envs) == 0) {
      if (messages | match_first) {
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
        matched <- envs[envs == envname]
        if(length(matched) == 1) {
          label <- "exact"
          envname <- matched
        }
        if (length(matched) == 0 && match_first) {
          label <- "approximate"
          envname <- envs[[1]]
          if (messages) {
            msg_1 <- "{.header A Python environment with a matching version was not found}"
            msg_2 <- "{.header Will attempt connecting using }{.emph '{envname}'}"
            msg_3 <- "{.header To install the exact Python environment use: {.run {run_code}}}"
            cli_div(theme = cli_colors())
            cli_alert_warning(msg_1)
            cli_bullets(c(" " = msg_2, " " = msg_3))
            cli_end()
          }
        }
      } else {
        label <- "first"
        envname <- envs[[1]]
      }
    }
  } else {
    envname_null <- FALSE
  }
  if(ask_if_not_installed &&
     interactive() &&
     envname_null &&
     label == "unavailable"
     ) {
    cli_alert_warning("No viable Python Environment was found.")
    cli_bullets(c(" " = "Do you wish to create one?"))
    utils::menu(choices = c("Yes", "No", "Cancel"))
  }

  envname <- set_names(as.character(envname), label)
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
