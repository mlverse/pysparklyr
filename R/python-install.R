#' Installs PySpark and Python dependencies
#' @param version Version of 'pyspark' to install. Defaults to `NULL`. If `NULL`,
#'   it will check against PyPi to get the current library version.
#' @param envname The name of the Python Environment to use to install the
#'   Python libraries. Defaults to `NULL.` If `NULL`, a name will automatically
#'   be assigned based on the version that will be installed
#' @param python_version The minimum required version of Python to use to create
#' the Python environment. Defaults to `NULL`. If `NULL`, it will check against
#' PyPi to get the minimum required Python version.
#' @param new_env If `TRUE`, any existing Python virtual environment and/or
#'   Conda environment specified by `envname` is deleted first.
#' @param method The installation method to use. If creating a new environment,
#'   `"auto"` (the default) is equivalent to `"virtualenv"`. Otherwise `"auto"`
#'   infers the installation method based on the type of Python environment
#'   specified by `envname`.
#' @param ... Passed on to [`reticulate::py_install()`]
#' @param as_job Runs the installation if using this function within the
#' RStudio IDE.
#' @param install_ml Installs ML related Python libraries. Defaults to TRUE. This
#' is mainly for machines with limited storage to avoid installing the rather
#' large 'torch' library if the ML features are not going to be used. This will
#' apply to any environment backed by 'Spark' version 3.5 or above.
#' @returns It returns no value to the R session. This function purpose is to
#' create the 'Python' environment, and install the appropriate set of 'Python'
#' libraries inside the new environment. During runtime, this function will send
#' messages to the console describing the steps that the function is
#' taking. For example, it will let the user know if it is getting the latest
#' version of the Python library from 'PyPi.org', and the result of such
#' query.
#' @export
install_pyspark <- function(
    version = NULL,
    envname = NULL,
    python_version = NULL,
    new_env = TRUE,
    method = c("auto", "virtualenv", "conda"),
    as_job = TRUE,
    install_ml = FALSE,
    ...) {
  install_as_job(
    main_library = "pyspark",
    spark_method = "pyspark_connect",
    backend = "pyspark",
    ml_version = "3.5",
    version = version,
    envname = envname,
    python_version = python_version,
    new_env = new_env,
    method = method,
    as_job = as_job,
    install_ml = install_ml,
    ... = ...
  )
}

#' Installs Databricks Connect and Python dependencies
#' @param version Version of 'databricks.connect' to install. Defaults to `NULL`.
#'  If `NULL`, it will check against PyPi to get the current library version.
#' @param cluster_id Target of the cluster ID that will be used with.
#' If provided, this value will be used to extract the cluster's
#' version
#' @rdname install_pyspark
#' @export
install_databricks <- function(
    version = NULL,
    cluster_id = NULL,
    envname = NULL,
    python_version = NULL,
    new_env = TRUE,
    method = c("auto", "virtualenv", "conda"),
    as_job = TRUE,
    install_ml = FALSE,
    ...) {
  if (!is.null(version) && !is.null(cluster_id)) {
    cli_div(theme = cli_colors())
    cli_alert_warning(
      paste0(
        "{.header Will use the value from }{.emph 'version'}, ",
        "{.header and ignoring }{.emph 'cluster_id'}"
      )
    )
    cli_end()
  }

  if (is.null(envname)) {
    if (is.null(version) && !is.null(cluster_id)) {
      version <- databricks_dbr_version(
        cluster_id = cluster_id,
        host = databricks_host(),
        token = databricks_token()
      )
    }
  }

  install_as_job(
    main_library = "databricks-connect",
    spark_method = "databricks_connect",
    backend = "databricks",
    ml_version = "14.1",
    version = version,
    envname = envname,
    python_version = python_version,
    new_env = new_env,
    method = method,
    as_job = as_job,
    install_ml = install_ml,
    ... = ...
  )
}

install_as_job <- function(
    main_library = NULL,
    spark_method = NULL,
    backend = NULL,
    ml_version = NULL,
    version = NULL,
    envname = NULL,
    python_version = NULL,
    new_env = NULL,
    method = c("auto", "virtualenv", "conda"),
    as_job = TRUE,
    install_ml = TRUE,
    ...) {
  args <- c(as.list(environment()), list(...))
  if (as_job && check_rstudio()) {
    install_code <- build_job_code(args)
    job_name <- paste0("Installing '", main_library, "' version '", version, "'")
    temp_file <- tempfile()
    writeLines(install_code, temp_file)
    invisible(
      jobRunScript(path = temp_file, name = job_name)
    )
    cli_div(theme = cli_colors())
    cli_alert_success("{.header Running installation as a RStudio job }")
    cli_end()
  } else {
    install_environment(
      main_library = main_library,
      spark_method = spark_method,
      backend = backend,
      ml_version = ml_version,
      version = version,
      envname = envname,
      python_version = python_version,
      new_env = new_env,
      method = method,
      install_ml = install_ml,
      ... = ...
    )
  }
}

install_environment <- function(
    main_library = NULL,
    spark_method = NULL,
    backend = NULL,
    ml_version = NULL,
    version = NULL,
    envname = NULL,
    python_version = NULL,
    new_env = NULL,
    method = c("auto", "virtualenv", "conda"),
    install_ml = FALSE,
    install_packages = NULL,
    ...) {
  if (is.null(version)) {
    lib <- py_library_info(main_library)
    version <- lib$version
  } else {
    lib <- py_library_info(main_library, version)
    if (is.null(lib)) {
      cli_alert_success(
        "{.header Checking if provided version is valid against PyPi.org}"
      )
      cli_abort(
        "{.header Version } {.emph '{version}' }{.header does not exist}"
      )
    }
  }

  ver_name <- version_prep(version)

  if (version == ver_name) {
    version <- paste0(version, ".*")
  }

  add_torch <- TRUE
  if (is.null(envname)) {
    ver_compare <- compareVersion(
      as.character(ver_name),
      as.character(ml_version)
    )
    if (ver_compare < 0) {
      add_torch <- FALSE
    }
    envname <- use_envname(
      backend = backend,
      version = ver_name,
      ask_if_not_installed = FALSE
    )
  }
  cli_alert_success(
    "Automatically naming the environment:{.emph '{envname}'}"
  )

  packages <- c(
    paste0(main_library, "==", version),
    "pandas!=2.1.0", # deprecation warnings
    "PyArrow",
    "grpcio",
    "google-api-python-client",
    "grpcio_status"
  )

  if (add_torch && install_ml) {
    packages <- c(packages, pysparklyr_env$ml_libraries)
  }

  method <- match.arg(method)

  if (new_env) {
    if (method %in% c("auto", "virtualenv")) {
      tryCatch(virtualenv_remove(envname, confirm = FALSE), error = identity)
    }
    if (method %in% c("auto", "conda")) {
      conda <- list(...)$conda %||% "auto"
      while (!inherits(
        tryCatch(conda_python(envname, conda), error = identity),
        "error"
      )) {
        conda_remove(envname, conda = conda)
      }
    }
  }

  if (new_env && method != "conda" &&
    is.null(virtualenv_starter(python_version))) {
    cli_abort(paste(
      "Python version 3.9 or higher is required by some libraries.",
      "Use: {.run reticulate::install_python(version = '3.9:latest')}",
      "to install."
    ))
  }

  if (dir.exists("/databricks/")) {
    # https://github.com/mlverse/pysparklyr/issues/11
    op <- options("reticulate.virtualenv.module" = "virtualenv")
    on.exit(options(op))
  }

  # conda_install() doesn't accept a version constraint for python_version
  if (method == "conda" && python_version == ">=3.9") {
    python_version <- "3.9"
  }

  if (!is.null(install_packages)) {
    packages <- install_packages
  }

  py_install(
    packages = packages,
    envname = envname,
    method = method,
    python_version = python_version,
    pip = TRUE,
    ... = ...
  )
}

#' Lists installed Python libraries
#' @param list_all Flag that indicates to display all of the installed packages
#' or only the top two, namely, `pyspark` and `databricks.connect`
#' @returns Returns no value, only sends information to the console. The
#' information includes the current versions of 'sparklyr', and 'pysparklyr',
#' as well as the 'Python' environment currently loaded.
#' @export
installed_components <- function(list_all = FALSE) {
  pkgs <- py_list_packages()
  db <- pkgs$package == "databricks-connect"
  ps <- pkgs$package == "pyspark"
  sel <- db | ps
  if (!list_all) {
    new_pkgs <- pkgs[sel, ]
  } else {
    new_pkgs <- rbind(pkgs[sel, ], pkgs[!sel, ])
  }
  cli_div(theme = cli_colors())
  cli_h3("R packages")
  cli_bullets(c("*" = "{.header {.code sparklyr} ({packageVersion('sparklyr')}})"))
  cli_bullets(c("*" = "{.header {.code pysparklyr} ({packageVersion('pysparklyr')}})"))
  cli_bullets(c("*" = "{.header {.code reticulate} ({packageVersion('reticulate')}})"))
  cli_h3("Python executable")
  cli_text("{.header {py_exe()}}")
  cli_h3("Python libraries")
  for (i in seq_len(nrow(new_pkgs))) {
    curr_row <- new_pkgs[i, ]
    cli_bullets(c("*" = "{.header {curr_row$package} ({.header {curr_row$version}})}"))
  }
  cli_end()
  invisible()
}

py_library_info <- function(
    library_name,
    library_version = NULL,
    verbose = TRUE,
    timeout = 2
    ) {
  msg_fail <- NULL
  msg_done <- NULL
  ret <- NULL
  if(verbose) {
    cli_div(theme = cli_colors())
    resp <- query_pypi(library_name, library_version, timeout)
    cli_progress_step(
      "{.header Retrieving version from PyPi.org}",
      msg_done = paste0("{.header Using:} {.emph '{ret$name}'} {ret$version},",
                        " {.header requires Python }{ret$requires_python}"),
      msg_failed = "{.header {msg_fail}}"
    )
  }

  if(inherits(resp, "try-error")) {
    # Not catastrophic, it will simply try to use the upstream name and version
    # provided by the user
    msg_fail <- "Failed to contact PyPi.org"
    if(verbose) cli_progress_done(result = "failed")
    ret <- NULL
  } else {
    if(!is.null(resp)) {
      # Happy path :D
      ret <- resp$info
      cli_progress_done()
    } else {
      if(!is.null(library_version)) {
        # Quering PyPi again to see if at least the library name is valid
        resp2 <- query_pypi(library_name, timeout = timeout)
        if(!is.null(resp2)) {
          msg_abort <- c(
              "Version {.emph '{library_version}'} is not valid for {.emph '{library_name}'}",
              "i" = "{.header The most recent, valid, version is} {.emph '{resp2$info$version}'}"
              )
        } else {
          msg_abort <- "{.header Library }{.emph {library_name}} {.header not found.}"
        }
      }
      if(verbose) {
        cli_progress_done(result = "clear")
        cli_progress_cleanup()
      }
      # Failing despite 'verbose' set to FALSE (Catastrophic failure)
      cli_abort(msg_abort, call = NULL)
    }
  }
  ret
  # For possible future use
  # "https://packagemanager.posit.co/__api__/repos/5/packages/{library_name}"
}

query_pypi <- function(library_name, library_version = NULL, timeout) {
  url <- paste0("https://pypi.org/pypi/", library_name)
  if (!is.null(library_version)) {
    url <- paste0(url, "/", library_version)
  }
  url <- paste0(url, "/json")
  resp <- try({
    tryCatch(
      url %>%
        request() %>%
        req_timeout(timeout) %>%
        req_perform() %>%
        resp_body_json(),
      httr2_http_404 = function(cnd) NULL
    )},
    silent = TRUE
  )
  resp
}

version_prep <- function(version) {
  version <- as.character(version)
  ver <- version %>%
    strsplit("\\.") %>%
    unlist()

  ver_name <- NULL
  ver_len <- length(ver)

  if (ver_len == 1) {
    cli_abort(c(
      "{.emph '{version}' }{.header is not a valid version}",
      "{.header - Please provide major & minor version (e.g. {version}.0) }"
    ))
  }

  if (ver_len == 0) {
    cli_abort("{.emph '{version}' }{.header is not a valid version}")
  }

  out <- paste0(ver[1:2], collapse = ".")

  if (ver_len > 3) {
    cli_abort(c(
      "{.emph '{version}' }{.header contains too many version levels.}",
      "{.header - Please provide a major/minor version (e.g. {out})}"
    ))
  }

  out
}

check_rstudio <- function() {
  check_rstudio <- try(RStudio.Version(), silent = TRUE)
  if (inherits(check_rstudio, "try-error")) {
    return(FALSE)
  } else {
    return(TRUE)
  }
}

build_job_code <- function(args) {
  args$as_job <- NULL
  args$method <- args$method[[1]]
  arg_list <- args %>%
    imap(~ {
      if (inherits(.x, "character")) {
        x <- paste0("\"", .x, "\"")
      } else {
        x <- .x
      }
      paste0(.y, " = ", x)
    }) %>%
    as.character() %>%
    paste0(collapse = ", ")
  paste0(
    "pysparklyr:::install_environment(", arg_list, ")"
  )
}
