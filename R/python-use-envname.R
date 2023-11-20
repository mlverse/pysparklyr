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

  run_full <- "* {.header Run: {.run {run_code}} to install.}"

  sp_version <- version_prep(version)
  envname <- as.character(glue("{env_base}{sp_version}"))
  envs <- find_environments(env_base)

  match_one <- length(envs) > 1
  match_exact <- length(envs[envs == envname]) > 0

  if(!match_one && !match_exact) {
    msg <- paste0(
      "No {.emph viable} Python Environment was found for ",
      "{.emph {connection_label(method)}} version {.emph {version}}"
    )
    ret <- set_names(envname, "unavailable")
  }

  if(match_one && match_exact) {
    msg <- paste0(
      "No {.emph viable} Python Environment was found for ",
      "{.emph {connection_label(method)}} version {.emph {version}}"
    )
    ret <- set_names(envname, "exact")
  }

  if(match_one && !match_exact && match_first) {
    msg <- paste0(
      "No {.emph exact} Python Environment was found for ",
      "{.emph {connection_label(method)}} version {.emph {version}}",
      "If the exact version is not installed, {.code sparklyr} will ",
      "use {.code{envname}}"
    )
    ret <- set_names(env[1], "first")
  }

  if(match_one && !match_exact && !match_first) {
    msg <- paste0(
      "No {.emph exact} Python Environment was found for ",
      "{.emph {connection_label(method)}} version {.emph {version}}"
    )
    ret <-  set_names(envname, "unavailable")
  }

  ret_name <- names(ret)
  if(messages && ret != "exact") {
    cli_div(theme = cli_colors())
    if(ret_name == "unavailable") {
      cli_abort(c(msg, run_full))
    }
    if(ask_if_not_installed) {
      if(msg_prompt == "unavailable") {
        cli_alert_warning(msg)
      }
      cli_bullets(c(" " = "Do you wish to create one?"))
      utils::menu(choices = c("Yes", "No", "Cancel"))
    }
    cli_end()
  }

  ret
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
