#' Installs python dependencies
#' @param python_version The version of python to install if not available
#' @param virtualenv_name The name of the Virtual Environment to use to
#' install the python libraries. Defaults to "r-sparklyr".
#' @export
install_pyspark <- function(python_version = NULL,
                            virtualenv_name = "r-sparklyr") {
  if (!py_available()) {
    if (is.null(python_version)) {
      python_path <- install_python()
    } else {
      python_path <- install_python(version = python_version)
    }
    use_python(python = python_path)
  }

  if (!(virtualenv_name %in% virtualenv_list())) {
    virtualenv_create(virtualenv_name, package = NULL)
  }

  use_virtualenv(virtualenv_name)

  py_install(
    envname = virtualenv_name,
    packages = c(
      "pyspark", "pandas", "PyArrow", "grpcio", "google-api-python-client",
      "grpcio_status", "databricks-connect"
    ),
    pip_options = "--index-url https://packagemanager.posit.co/pypi/2023-06-01/simple"
  )
}
