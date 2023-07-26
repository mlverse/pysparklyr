#' Installs python dependencies
#' @param python_version The version of python to install if not available
#' @param virtualenv_name The name of the Virtual Environment to use to
#' install the python libraries. Defaults to "r-sparklyr".
#' @param force Flag that tells `reticulate` to re-create the Python Virtual
#' Environment even if one with the same name already exists
#' @param ignored_installed Flag that tells `reticulate` to ignore the Python
#' library installation if the given library is already installed
#' @export
install_pyspark <- function(python_version = NULL,
                            virtualenv_name = "r-sparklyr",
                            force = FALSE,
                            ignored_installed = TRUE
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
        "Python version 3.9 or higher is required by some of the needed",
        "libraries. Use: {.run reticulate::install_python(version = '3.9:latest')}",
        "to install."
        )
      )
  }

  virtualenv_create(
    virtualenv_name,
    version = version,
    pip_options = opts,
    force = force
  )

  py_install(
    packages = pkgs,
    envname = virtualenv_name,
    ignore_installed = ignored_installed,
    pip_options = opts
    )
}
