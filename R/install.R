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

  pkgs <- c(
    "pyspark", "pandas", "PyArrow", "grpcio", "google-api-python-client",
    "grpcio_status", "databricks-connect", "delta-spark"
  )

  opts <- "--index-url https://packagemanager.posit.co/pypi/2023-06-01/simple"

  virtualenv_create(
    virtualenv_name,
    version = ">=3.9",
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
