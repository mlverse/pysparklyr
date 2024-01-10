use_envname <- function(
    envname = NULL,
    backend = "pyspark",
    version = NULL,
    messages = FALSE,
    match_first = FALSE,
    ignore_reticulate_python = FALSE,
    ask_if_not_installed = interactive(),
    main_library = NULL
    ) {
  ret_python <- reticulate_python_check(ignore_reticulate_python)

  if (ret_python != "") {
    return(set_names(ret_python, "env_var"))
  }

  if (!is.null(envname)) {
    return(set_names(envname, "argument"))
  }

  if (is.null(version)) {
    cli_abort("A cluster {.code version} is required, please provide one")
  }

  env_base <- glue("r-sparklyr-{backend}-")
  run_code <- glue("pysparklyr::install_{backend}(version = \"{version}\")")
  run_full <- "{.header Run: {.run {run_code}} to install.}"

  con_label <- connection_label(backend)
  sp_version <- version_prep(version)
  envname <- as.character(glue("{env_base}{sp_version}"))
  envs <- find_environments(env_base)

  match_one <- length(envs) > 0
  match_exact <- length(envs[envs == envname]) > 0

  if(!is.null(main_library) && !match_exact) {
    lib_info <- python_library_info(main_library, fail = FALSE, verbose = FALSE)
    latest_ver <- lib_info$version
    install_recent <- compareVersion(latest_ver, version) == 1
  } else {
    install_recent <- TRUE
  }

  msg_exact <- paste0(
    "You do not have a Python environment that matches your {.emph {con_label}}",
    " cluster"
    )

  msg_1 <- NULL
  msg_2 <- NULL
  msg_yes <- NULL
  msg_no <- NULL
  msg_cancel <- NULL

  # There were 0 environments found
  if (!match_one && !match_exact) {
    ret <- set_names(envname, "unavailable")
    msg_1 <- env_notfound_msg("viable")
    msg_2 <- NULL
  }

  # Found an exact match
  if (match_one && match_exact) {
    ret <- set_names(envname, "exact")
    msg_1 <- env_notfound_msg("matching")
    msg_2 <- NULL
  }

  # There are environments, but no exact match, and argument says
  # to choose the most recent environment
  if (match_one && !match_exact && match_first) {
    ret <- set_names(envs[1], "first")
    if(install_recent) {
      msg_1 <- msg_exact
      msg_no <- glue(" - Will use alternate environment ({ret})")
    } else {
      ask_if_not_installed <- FALSE
      run_full <- NULL
      msg_1 <- paste0(
        "{.header Library {.emph {con_label}} version {.emph {version}} is not ",
        "yet available}"
      )
    }
  }

  # There are environments, but no exact match
  if (match_one && !match_exact && !match_first) {
    msg_1 <- msg_exact
    msg_2 <- "{.header The default Python environment may not work correctly}"
    msg_yes <- glue(" - Will install {con_label} {version}")
    ret <- set_names(envname, "unavailable")
  }

  ret_name <- names(ret)
  if (messages && ret_name != "exact") {
    cli_div(theme = cli_colors())
    if (ask_if_not_installed) {
      cli_alert_warning(msg_1)
      cli_bullets(c(
        " " = msg_2,
        " " = "Do you wish to install {con_label} version {version}?"
      ))
      choice <- menu(choices = c(
        paste0("Yes", msg_yes),
        paste0("No", msg_no),
        "Cancel"
        ))
      if (choice == 1) {
        ret <- set_names(envname, "prompt")
        exec(
          .fn = glue("install_{backend}"),
          version = version,
          as_job = FALSE
          )
      }
      if (choice == 2) {
        ret <- set_names(ret, "prompt")
      }
      if (choice == 3) {
        return(invisible())
      }
    } else {
      if (ret_name == "unavailable") {
        cli_abort(c(msg_1, msg_2, run_full))
      }
      if (ret_name == "first") {
        cli_alert_warning(msg_1)
        cli_bullets(c(
          " " = msg_2,
          " " = run_full
        ))
      }
    }
    cli_end()
  }
  ret
}

env_notfound_msg <- function(x) {
  paste0(
    "No {.emph ", x,"} Python Environment was found for ",
    "{.emph {con_label}} version {.emph {version}}"
  )
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
