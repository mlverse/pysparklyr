#' Installs PySpark and Python dependencies
#' @param version Version of 'pyspark' to install
#' @param envname The name of the Python Environment to use to install the
#'   Python libraries. Default to `NULL.` If `NULL`, a name will automatically
#'   be assigned based on the version that will be installed
#' @param python_version The version of Python to use to create the Python
#'   environment.
#' @param new_env If `TRUE`, any existing Python virtual environment and/or
#'   Conda environment specified by `envname` is deleted first.
#' @param method The installation method to use. If creating a new environment,
#'   `"auto"` (the default) is equivalent to `"virtualenv"`. Otherwise `"auto"`
#'   infers the installation method based on the type of Python environment
#'   specified by `envname`.
#' @param ... Passed on to [`reticulate::py_install()`]
#' @param as_job Runs the installation if using this function within the
#' RStudio IDE.
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
    python_version = ">=3.9",
    new_env = TRUE,
    method = c("auto", "virtualenv", "conda"),
    as_job = TRUE,
    ...) {
  install_as_job(
    libs = "pyspark",
    version = version,
    envname = envname,
    python_version = python_version,
    new_env = new_env,
    method = method,
    as_job = as_job,
    ... = ...
  )
}

#' Installs Databricks Connect and Python dependencies
#' @param version Version of 'databricks.connect' to install
#' @param cluster_id Target of the cluster ID that will be used with.
#' If provided, this value will be used to extract the cluster's
#' version
#' @rdname install_pyspark
#' @export
install_databricks <- function(
    version = NULL,
    cluster_id = NULL,
    envname = NULL,
    python_version = ">=3.9",
    new_env = TRUE,
    method = c("auto", "virtualenv", "conda"),
    as_job = TRUE,
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

  if (is.null(version) && !is.null(cluster_id)) {
    version <- cluster_dbr_version(cluster_id)
  }

  install_as_job(
    libs = "databricks-connect",
    version = version,
    envname = envname,
    python_version = python_version,
    new_env = new_env,
    method = method,
    as_job = as_job,
    ... = ...
  )
}

install_as_job <- function(
    libs = NULL,
    version = NULL,
    envname = NULL,
    python_version = NULL,
    new_env = NULL,
    method = c("auto", "virtualenv", "conda"),
    as_job = TRUE,
    ...) {
  args <- c(as.list(environment()), list(...))
  in_rstudio <- FALSE
  check_rstudio <- try(RStudio.Version(), silent = TRUE)
  if (!inherits(check_rstudio, "try-error")) {
    in_rstudio <- TRUE
  }
  if (as_job && in_rstudio) {
    args$as_job <- NULL
    args$method <- args$method[[1]]

    job_name <- paste0("Installing '", libs, "' version '", version, "'")

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

    install_code <- paste0(
      "pysparklyr:::install_environment(", arg_list, ")"
    )
    temp_file <- tempfile()
    writeLines(install_code, temp_file)
    invisible(
      jobRunScript(
        path = temp_file,
        name = job_name
      )
    )
    cli_div(theme = cli_colors())
    cli_alert_success("{.header Running installation as an RStudio job }")
    cli_end()
  } else {
    install_environment(
      libs = libs,
      version = version,
      envname = envname,
      python_version = python_version,
      new_env = new_env,
      method = method,
      ... = ...
    )
  }
}

install_environment <- function(
    libs = NULL,
    version = NULL,
    envname = NULL,
    python_version = NULL,
    new_env = NULL,
    method = c("auto", "virtualenv", "conda"),
    ...) {
  if (is.null(version)) {
    cli_div(theme = cli_colors())
    cli_alert_success(
      "{.header Retrieving version from PyPi.org}"
    )
    lib <- py_library_info(libs)
    version <- lib$version
    cli_alert_success("{.header Using version: }{.emph '{version}'}")
    cli_end()
  } else {
    lib <- py_library_info(libs, version)
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

  if (is.null(envname)) {
    if (libs == "databricks-connect") {
      ln <- "databricks"
    } else {
      ln <- libs
    }
    envname <- glue("r-sparklyr-{ln}-{ver_name}")
    cli_alert_success(
      "Automatically naming the environment:{.emph '{envname}'}"
    )
  }

  packages <- c(
    paste0(libs, "==", version),
    "pandas!=2.1.0", # deprecation warnings
    "PyArrow",
    "grpcio",
    "google-api-python-client",
    "grpcio_status",
    "torch",
    "torcheval"
  )

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

py_library_info <- function(lib, ver = NULL) {
  url <- paste0("https://pypi.org/pypi/", lib)
  if (!is.null(ver)) {
    url <- paste0(url, "/", ver)
  }
  url <- paste0(url, "/json")
  resp <- tryCatch(
    url %>%
      request() %>%
      req_perform() %>%
      resp_body_json(),
    httr2_http_404 = function(cnd) NULL
  )

  resp$info
  # For possible future use
  # "https://packagemanager.posit.co/__api__/repos/5/packages/{lib}"
}

version_prep <- function(version) {
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
