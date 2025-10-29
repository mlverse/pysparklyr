use_envname <- function(
    envname = NULL,
    backend = "pyspark",
    version = NULL,
    messages = FALSE,
    match_first = FALSE,
    ignore_reticulate_python = FALSE,
    ask_if_not_installed = FALSE,
    main_library = NULL,
    python_version = NULL) {
  if (is.null(main_library) && !is.null(backend)) {
    if (backend == "pyspark") {
      main_library <- "pyspark"
    } else if (backend == "databricks") {
      main_library <- "databricks.connect"
    } else if (backend == "snowflake") {
      main_library <- "snowflake-snowpark-python"
    } else {
      cli_abort("Backend `{backend}` not valid")
    }
  }
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
    if (!is.null(lib_info)) {
      latest_ver <- lib_info$version
      if(version == "latest") {
        version <- latest_ver
      }
      vers <- compareVersion(latest_ver, version)
      install_recent <- vers == 1
      # For cases when the cluster's version is higher than the latest library
      if (vers == -1) {
        envname <- as.character(glue("{env_base}{latest_ver}"))
        install_ver <- latest_ver
      }
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
          backend = backend,
          main_library = main_library,
          version = version,
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

python_requirements <- function(
    backend = NULL,
    main_library = NULL,
    ml_version = NULL,
    version = NULL,
    python_version = NULL,
    install_ml = FALSE,
    add_torch = FALSE) {
  cli_div(theme = cli_colors())

  if (is.null(python_version) && backend == "databricks") {
    python_version <- databricks_dbr_python(version)
  }

  library_info <- python_library_info(
    library_name = main_library,
    library_version = version,
    verbose = is.null(python_version)
  )

  if (!is.null(library_info)) {
    if (is.null(python_version)) {
      python_version <- library_info$requires_python
    }
    version <- library_info$version
    ver_name <- version
  } else {
    if (!is.null(version)) {
      ver_name <- version_prep(version)
      if (version == ver_name) {
        version <- paste0(version, ".*")
      }
    } else {
      cli_abort(
        c(
          "No `version` provided, and none could be found",
          " " = "Please run again with a valid version number"
        ),
        call = NULL
      )
    }
  }

  requires_dist <- as.character(library_info$requires_dist)
  packages <- c(
    paste0(main_library, "==", version),
    if (length(requires_dist)) {
      with_extra <- grepl("; extra", requires_dist)
      extra_str <- strsplit(requires_dist[with_extra], "; extra")
      extra_str <- lapply(extra_str, function(x) x[[1]])
      extra_str <- as.character(extra_str)
      extra_str <- unique(extra_str)
      c(requires_dist[!with_extra], extra_str)
    } else {
      c(
        "pandas!=2.1.0", # deprecation warnings
        "PyArrow",
        "grpcio",
        "google-api-python-client",
        "grpcio_status"
      )
    }
  )

  if (add_torch && install_ml) {
    packages <- c(packages, pysparklyr_env$ml_libraries)
  }

  packages <- c(packages, "pip")

  list(
    packages = packages,
    python_version = python_version
  )
}
