use_envname <- function(
  envname = NULL,
  backend = "pyspark",
  backend_version = NULL,
  main_library_version = backend_version,
  messages = FALSE,
  match_first = FALSE,
  ignore_reticulate_python = FALSE,
  ask_if_not_installed = FALSE,
  main_library = NULL,
  python_version = NULL
) {
  if (is.null(main_library) && !is.null(backend)) {
    cli_abort("Backend `{backend}` not valid")
  }
  # Back-ends whose library is versioned separately (e.g. Sail) pass
  # `main_library_version`. `missing()` does not force the promise, so a lazy
  # lookup is only run if needed
  library_version_separate <- !missing(main_library_version)
  cli_div(theme = cli_colors())

  ret_python <- reticulate_python_check(ignore_reticulate_python, unset = FALSE)

  if (ret_python != "") {
    return(set_names(ret_python, "env_var"))
  }

  if (!is.null(envname)) {
    return(set_names(envname, "argument"))
  }

  version_from_pypi <- FALSE
  if (is.null(backend_version)) {
    if (!is.null(main_library) && !library_version_separate) {
      lib_info <- python_library_info(
        main_library,
        fail = FALSE,
        verbose = FALSE
      )
      if (!is.null(lib_info)) {
        backend_version <- lib_info$version
        version_from_pypi <- TRUE
      }
    }
    if (is.null(backend_version)) {
      cli_abort("A cluster {.code version} is required, please provide one")
    }
  }
  if (!library_version_separate) {
    main_library_version <- backend_version
  }

  env_base <- glue("r-sparklyr-{backend}-")
  run_code <- glue(
    "pysparklyr::install_{backend}(version = \"{backend_version}\")"
  )
  run_full <- "{.header Run: {.run {run_code}} to install.}"

  con_label <- connection_label(backend)
  sp_version <- version_prep(backend_version)
  envname <- as.character(glue("{env_base}{sp_version}"))
  envs <- find_environments(env_base)

  match_one <- length(envs) > 0
  match_exact <- length(envs[envs == envname]) > 0
  install_ver <- backend_version

  install_recent <- TRUE
  if (!is.null(main_library) && !match_exact) {
    lib_info <- python_library_info(main_library, fail = FALSE, verbose = FALSE)
    if (!is.null(lib_info)) {
      latest_ver <- lib_info$version
      if (main_library_version == "latest") {
        main_library_version <- latest_ver
        if (!library_version_separate) {
          backend_version <- latest_ver
        }
      }
      vers <- compareVersion(latest_ver, main_library_version)
      # A separately versioned library comes from a published pin, so it is
      # never "not yet available"
      install_recent <- vers == 1 || library_version_separate
      # For cases when the cluster's version is higher than the latest library.
      # Only meaningful when both versions share the same scale
      if (vers == -1 && !library_version_separate) {
        envname <- as.character(glue("{env_base}{latest_ver}"))
        install_ver <- latest_ver
      }
    }
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
    ret_name <- if (version_from_pypi) "latest" else "unavailable"
    ret <- set_names(envname, ret_name)
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
        "{.header Library {.emph {con_label}} version ",
        "{.emph {main_library_version}} is not ",
        "yet available}"
      )
    }
  }

  # There are environments, but no exact match
  if (match_one && !match_exact && !match_first) {
    msg_1 <- msg_default
    msg_no <- " - Will use the default Python environment"
    ret_name <- if (version_from_pypi) "latest" else "unavailable"
    ret <- set_names(envname, ret_name)
  }

  ret_name <- names(ret)
  if (messages && ret_name != "exact") {
    if (ask_if_not_installed) {
      cli_alert_warning(msg_1)
      cli_bullets(c(
        " " = msg_2,
        " " = "{.header Do you wish to install {con_label} version {install_ver}?}"
      ))
      choice <- menu(
        choices = c(
          paste0("Yes", msg_yes),
          paste0("No", msg_no),
          "Cancel"
        )
      )
      if (choice == 1) {
        ret <- set_names(envname, "prompt")
        exec(
          .fn = glue("install_{backend}"),
          version = backend_version,
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
      # `py_require()` can only declare ephemeral environment requirements
      # before Python initializes. Once it has, re-declaring packages that are
      # already in the requirements (e.g. on a second connection in the same
      # session) emits reticulate's "After Python has initialized, only
      # `action = 'add'` with new packages is supported" warning, and the
      # environment is fixed anyway. So only declare requirements pre-init.
      if (
        ret_name %in%
          c("unavailable", "latest") &&
          !reticulate::py_available(initialize = FALSE)
      ) {
        reqs <- python_requirements(
          backend = backend,
          main_library = main_library,
          backend_version = backend_version,
          main_library_version = main_library_version,
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
  backend_version = NULL,
  main_library_version = backend_version,
  python_version = NULL,
  install_ml = FALSE,
  add_torch = FALSE
) {
  cli_div(theme = cli_colors())

  if (is.null(python_version) && backend == "databricks") {
    python_version <- databricks_dbr_python(backend_version)
  }

  library_info <- python_library_info(
    library_name = main_library,
    library_version = main_library_version,
    verbose = is.null(python_version)
  )

  if (!is.null(library_info)) {
    if (is.null(python_version)) {
      python_version <- library_info$requires_python
    }
    main_library_version <- library_info$version
  } else {
    if (!is.null(main_library_version)) {
      ver_name <- version_prep(main_library_version)
      if (main_library_version == ver_name) {
        main_library_version <- paste0(main_library_version, ".*")
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
    paste0(main_library, "==", main_library_version),
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
        "grpcio_status",
        "databricks-sdk",
        "zstandard"
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
