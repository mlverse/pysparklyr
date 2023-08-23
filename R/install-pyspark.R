#' Installs python dependencies
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
install_pyspark <- function(envname = "r-sparklyr",
                            ...,
                            python_version = ">=3.9",
                            new_env = identical(envname, "r-sparklyr"),
                            method = c("auto", "virtualenv", "conda")) {
  packages <- c(
    "pyspark",
    "pandas",
    "PyArrow",
    "grpcio",
    "google-api-python-client",
    "grpcio_status",
    "databricks-connect",
    "delta-spark"
  )

  pip_options <- "--index-url https://packagemanager.posit.co/pypi/2023-06-15/simple"
  # in cause user supplied pip_options in ...
  pip_options <- c(pip_options, list(...)$pip_options)

  method <- match.arg(method)

  if (new_env) {
    if (method %in% c("auto", "virtualenv")) {
      tryCatch(virtualenv_remove(envname, confirm = FALSE), error = identity)
    }
    if (method %in% c("auto", "conda")) {
      tryCatch(conda_remove(envname, conda = list(...)$conda %||% "auto"),
        error = identity
      )
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
    pip_options = pip_options,
    ...
  )
}

#' Lists installed Python libraries
#' @param list_all Flag that indicates to display all of the installed packages
#' or only the top two, namely, `pyspark` and `databricks.connect`
#' @export
installed_versions <- function(list_all = FALSE) {
  pkgs <- py_list_packages()
  db <- pkgs$package == "databricks-connect"
  ps <- pkgs$package == "pyspark"
  sel <- db | ps
  if(!list_all) {
    new_pkgs <- pkgs[sel, ]
  } else {
    new_pkgs <- rbind(pkgs[sel, ], pkgs[!sel, ])
  }
  cli_div(theme = cli_colors())
  cli_text("{.class Python executable: {py_exe()}}")
  for(i in seq_len(nrow(new_pkgs))) {
    curr_row <- new_pkgs[i, ]
    cli_li("{.header {curr_row$package} ({.header {curr_row$version}})}")
  }
  cli_end()
  invisible()


}
