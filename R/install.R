#' Installs python dependencies
#' @param python_version The version of python to install if not available
#' @param virtualenv_name The name of the Virtual Environment to use to
#' install the python libraries. Defaults to "r-sparklyr".
#' @param force Flag that tells `reticulate` to re-create the Python Virtual
#' Environment even if one with the same name already exists
#' @param ignored_installed Flag that tells `reticulate` to ignore the Python
#' library installation if the given library is already installed
#' @param method Installation method. By default, "auto" automatically finds
#'  a method that will work in the local environment. Change the default to
#'  force a specific installation method. Note that the "virtualenv" method is
#'   not available on Windows.
#' @export
install_pyspark <- function(virtualenv_name = "r-sparklyr",
                            python_version = NULL,
                            force = FALSE,
                            ignored_installed = TRUE,
                            method = c("auto", "virtualenv", "conda")
                            ) {

  version <- ">=3.9"

  pkgs <- c(
    "pyspark", "pandas", "PyArrow", "grpcio", "google-api-python-client",
    "grpcio_status", "databricks-connect", "delta-spark"
  )

  opts <- "--index-url https://packagemanager.posit.co/pypi/2023-06-01/simple"

  if(is.null(virtualenv_starter(version))) {
    cli_abort(
      paste(
        "Python version 3.9 or higher is required by some libraries.",
        "Use: {.run reticulate::install_python(version = '3.9:latest')}",
        "to install."
        )
      )
  }

  py_install(
    packages = pkgs,
    envname = virtualenv_name,
    ignore_installed = ignored_installed,
    pip_options = opts,
    method = method,
    version = version,
    force = force
    )
}
