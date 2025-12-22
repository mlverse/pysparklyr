#' Starts and stops Spark Connect locally
#' @param version Spark version to use (3.4 or above)
#' @param scala_version Acceptable Scala version of packages to be loaded
#' @param include_args Flag that indicates whether to add the additional arguments
#' to the command that starts the service. At this time, only the 'packages'
#' argument is submitted.
#' @param python_version Python version to use if a temporary Python environment
#' will be created
#' @param python Path to the Python executable to use while running (optional)
#' @param ... Optional arguments; currently unused
#' @returns It returns messages to the console with the status of starting, and
#' stopping the local Spark Connect service.
#' @export
spark_connect_service_start <- function(version = "4.0",
                                        scala_version = "2.13",
                                        python_version = NULL,
                                        python = NULL,
                                        include_args = TRUE,
                                        ...) {
  get_version <- spark_install_find(version = version)
  cmd <- path(get_version$sparkVersionDir, "sbin", "start-connect-server.sh")
  args <- c(
    "--packages",
    glue("org.apache.spark:spark-connect_{scala_version}:{get_version$sparkVersion}")
  )
  if (!include_args) {
    args <- ""
  }
  cli_div(theme = cli_colors())
  cli_text("{.header Starting {.emph Spark Connect} locally ...}")
  java_version <- try(
    system2("java", "-version", stdout = TRUE, stderr = TRUE),
    silent = TRUE
  )
  if (!inherits(java_version, "try-error")) {
    out_java <- setNames(java_version, rep("", times = length(java_version)))
    cli_bullets(out_java)
  }
  if(is.null(python)) {
    envname <- use_envname(
      backend = "pyspark",
      main_library = "pyspark",
      version = version,
      python_version = python_version,
      messages = TRUE,
      ask_if_not_installed = FALSE
    )
    py_require("rpy2")
    invisible(import_check("pyspark", envname))
    python <- py_exe()
  }
  withr::with_envvar(
    new = c(
      "PYSPARK_PYTHON" = python,
      "PYTHON_VERSION_MISMATCH" = python,
      "PYSPARK_DRIVER_PYTHON" = python
    ),
    {
      prs <- process$new(
        command = cmd,
        args = args,
        stdout = "|",
        stderr = "|",
        stdin = "|"
      )
    }
  )


  output <- prs$read_all_output()
  cli_bullets(c(" " = "{.info {output}}"))
  error <- prs$read_all_error()
  if (error != "") {
    cli_abort(error)
  }
  cli_end()
  invisible()
}

#' @rdname spark_connect_service_start
#' @export
spark_connect_service_stop <- function(version = "4.0", ...) {
  get_version <- spark_install_find(version = version)
  cmd <- path(get_version$sparkVersionDir, "sbin", "stop-connect-server.sh")
  cli_div(theme = cli_colors())
  cli_h3("{.header Stopping {.emph Spark Connect}}")
  prs <- process$new(
    command = cmd,
    stdout = "|",
    stderr = "|",
    stdin = "|"
  )
  cli_bullets(c(" " = "{.info - Shutdown command sent}"))
  cli_end()
}
