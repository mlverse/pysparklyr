use_envname <- function(
    envname = NULL,
    method = "spark_connect",
    version = NULL,
    messages = FALSE,
    match_first = FALSE,
    ignore_reticulate_python = FALSE,
    ask_if_not_installed = interactive()
    ) {

  if(!is.null(envname)) {
    return(set_names(envname, "argument"))
  }

  if(is.null(version)) {
    cli_abort("A cluster {.code version} is required, please provide one")
  }

  reticulate_python_check(ignore_reticulate_python)

  if (method == "spark_connect") {
    env_base <- "r-sparklyr-pyspark-"
    run_code <- glue("pysparklyr::install_pyspark(version = \"{version}\")")
  } else {
    env_base <- "r-sparklyr-databricks-"
    run_code <- glue("pysparklyr::install_databricks(version = \"{version}\")")
  }

  sp_version <- version_prep(version)
  envname <- as.character(glue("{env_base}{sp_version}"))
  envs <- find_environments(env_base)

  match_one <- length(envs) > 1
  match_exact <- length(envs[envs == envname]) > 0

  if(!match_one && !match_exact) {
    ret <- set_names(envname, "unavailable")
  }

  if(match_one && match_exact) {
    ret <- set_names(envname, "exact")
  }

  if(match_one && !match_exact && match_first) {
    ret <- set_names(env[1], "first")
  }

  if(match_one && !match_exact && !match_first) {
    ret <-  set_names(envname, "unavailable")
  }

  if(messages) {
    cli_div(theme = cli_colors())
    cli_alert_warning("No viable Python Environment was found")
    cli_bullets(c(
      " " = "for {.emph {connection_label(method)}} version {.emph {version}}"
    ))
    if(ask_if_not_installed) {
      cli_bullets(c(" " = "Do you wish to create one?"))
      utils::menu(choices = c("Yes", "No", "Cancel"))
    }
    cli_end()
  }

  ret
}
old_function <- function() {

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
