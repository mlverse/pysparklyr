#' Installs Pyspark and Python dependencies
#' @param version Version of 'pyspark' to install
#' @param envname The name of the Python Environment to use to install the
#'   Python libraries. Defaults to "r-sparklyr".
#' @param python_version The version of Python to use to create the Python
#'   environment.
#' @param new_env If `TRUE`, any existing Python virtual environment and/or
#'   Conda environment specified by `envname` is deleted first.
#' @param method The installation method to use. If creating a new environment,
#'   `"auto"` (the default) is equivalent to `"virtualenv"`. Otherwise `"auto"`
#'   infers the installation method based on the type of Python environment
#'   specified by `envname`.
#' @param ... Passed on to [`reticulate::py_install()`]
#' @export
install_pyspark <- function(
    version = NULL,
    envname = NULL,
    python_version = ">=3.9",
    new_env = TRUE,
    method = c("auto", "virtualenv", "conda"),
    ...) {

  install_environment(
    libs = "pyspark",
    version = version,
    envname = envname,
    python_version = python_version,
    new_env = new_env,
    method = method,
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
    ...) {

  if (!is.null(version) && !is.null(cluster_id)) {
    cli_div(theme = cli_colors())
    cli_alert_warning(
      paste0(
        "{.header Will use the value from }{.emph 'version'},",
        "{.header and ignoring }{.emph 'cluster_id'}"
      )
    )
    cli_end()
  }

  if (is.null(version) && !is.null(cluster_id)) {
    cli_div(theme = cli_colors())
    cli_alert_warning(
      "{.header Retrieving version from cluster }{.emph '{cluster_id}'}"
    )
    version <- cluster_dbr_version(cluster_id)
    cli_alert_success("{.header Cluster version: }{.emph '{version}'}")
    cli_end()
  }

  install_environment(
    libs = "databricks-connect",
    version = version,
    envname = envname,
    python_version = python_version,
    new_env = new_env,
    method = method,
    ... = ...
  )
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
      "{.header Retrieving version from PyPi}"
    )
    lib <- py_library_info(libs)
    version <- lib$version
    cli_alert_success("{.header Using version: }{.emph '{version}'}")
    cli_end()
  } else {
    lib <- py_library_info(libs, version)
    if(is.null(lib)) {
      cli_alert_success(
        "{.header Checking if provided version is valid against PyPi}"
        )
      cli_abort(
        "{.header Version } {.emph '{version}' }{.header does not exist}"
      )
    }
  }

  ver <- version %>%
    strsplit("\\.") %>%
    unlist()

  ver_name <- version
  ver_len <- length(ver)

  if (ver_len == 1) {
    cli_abort(c(
      "{.emph '{version}' }{.header is not a valid version}",
      "{.header - Please provide major & minor version (e.g. 10.2) }"
    ))
  }

  if (ver_len > 3 | ver_len == 0) {
    cli_abort("{.emph '{version}' }{.header is not a valid version}")
  }

  if (ver_len == 2) {
    version <- paste0(version, ".*")
  }

  if (ver_len == 3) {
    ver_name <- paste0(ver[1:2], collapse = ".")
  }

  if (is.null(envname)) {
    if(libs == "databricks-connect") {
      ln <- "databricks"
    } else {
      ln <- libs
    }
    envname <- glue("r-sparklyr-{ln}-{ver_name}")
  }

  cli_alert_success(
    "Automatically naming the environment:{.emph '{envname}'}"
  )

  if (!is.null(version)) {
    libs <- paste0(libs, "==", version)
  }

  packages <- c(
    libs,
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

require_python <- function(package, version) {
  pkgs <- py_list_packages()
  match <- pkgs[pkgs$package == package, ]
  comp_ver <- compareVersion(version, match$version)
  if (comp_ver == 1) {
    cli_div(theme = cli_colors())
    cli_abort(c(
      paste0(
        "{.header A minimum version of} '{version}'",
        " {.header for}", " `{package}` {.header is required.} ",
        "{.header Currently, version} '{match$version}' {.header is installed.}"
      ),
      paste0(
        "Use {.run pysparklyr::install_pyspark()}",
        " to install the latest versions of the libraries."
      ),
      "Make sure to restart your R session before trying again."
    ), call = NULL)
    cli_end()
  }
}

check_full_version <- function(x) {
  if (!is.null(x)) {
    ver <- unlist(strsplit(x, "\\."))
    if (length(ver) < 3) {
      cli_abort(paste(
        "Version provided {.emph '{x}'} is not valid.",
        "Please provide a full version."
      ))
    }
  }
}

py_library_info <- function(lib, ver = NULL) {
  url <- paste0("https://pypi.org/pypi/", lib)
  if(!is.null(ver)) {
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
