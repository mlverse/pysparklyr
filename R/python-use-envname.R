use_envname <- function(
    envname = NULL,
    backend = "pyspark",
    version = NULL,
    messages = FALSE,
    match_first = FALSE,
    ignore_reticulate_python = FALSE,
    ask_if_not_installed = interactive(),
    main_library = "pyspark",
    python_version = NULL) {
  cli_div(theme = cli_colors())

  ret_python <- reticulate_python_check(ignore_reticulate_python, unset = FALSE)

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
  install_ver <- version

  if (!is.null(main_library) && !match_exact) {
    lib_info <- python_library_info(main_library, fail = FALSE, verbose = FALSE)
    latest_ver <- lib_info$version
    vers <- compareVersion(latest_ver, version)
    install_recent <- vers == 1
    # For cases when the cluster's version is higher than the latest library
    if (vers == -1) {
      envname <- as.character(glue("{env_base}{latest_ver}"))
      install_ver <- latest_ver
    }
  } else {
    install_recent <- TRUE
  }

  msg_default <- paste0(
    "{.header You do not have a Python environment that matches your",
    " {.emph {con_label}} cluster}"
  )

  msg_1 <- NULL
  msg_2 <- NULL
  msg_yes <- NULL
  msg_no <- NULL

  # There were 0 environments found
  if (!match_one && !match_exact) {
    ret <- set_names(envname, "unavailable")
    msg_1 <- msg_default
    msg_no <- " - Will use the default Python environment"
  }

  # Found an exact match
  if (match_one && match_exact) {
    ret <- set_names(envname, "exact")
  }

  # There are environments, but no exact match, and argument says
  # to choose the most recent environment
  if (match_one && !match_exact && match_first) {
    ret <- set_names(envs[1], "first")
    if (install_recent) {
      msg_1 <- msg_default
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
    msg_1 <- msg_default
    msg_no <- " - Will use the default Python environment"
    ret <- set_names(envname, "unavailable")
  }

  ret_name <- names(ret)
  if (messages && ret_name != "exact") {
    if (ask_if_not_installed) {
      cli_alert_warning(msg_1)
      cli_bullets(c(
        " " = msg_2,
        " " = "{.header Do you wish to install {con_label} version {install_ver}?}"
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
        stop_quietly()
      }
    } else {
      if (ret_name == "unavailable") {
        reqs <- python_requirements(
          main_library = main_library,
          ml_version = ml_version,
          version = version ,
          python_version = python_version,
          install_ml = FALSE,
          add_torch = FALSE
          )
        reticulate::py_require(
          packages = reqs$packages,
          python_version = reqs$python_version
          )
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

find_environments <- function(x) {
  conda_names <- tryCatch(conda_list()$name, error = function(e) character())
  ve_names <- virtualenv_list()
  all_names <- c(ve_names, conda_names)
  sub_names <- substr(all_names, 1, nchar(x))
  matched <- all_names[sub_names == x]
  sorted <- sort(matched, decreasing = TRUE)
  sorted
}
