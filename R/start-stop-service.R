#' Starts and stops Spark Connect locally
#' @param version Spark version to use (3.4 or above)
#' @param scala_version Acceptable Scala version of packages to be loaded
#' @param include_args Flag that indicates whether to add the additional arguments
#' to the command that starts the service. At this time, only the 'packages'
#' argument is submitted.
#' @param python_version Python version to use if a temporary Python environment
#' will be created
#' @param python Path to the Python executable to use while running (optional)
#' @param additional_args Vector of additional arguments to use when starting
#' the service
#' @param ... Optional arguments; currently unused
#' @returns It returns messages to the console with the status of starting, and
#' stopping the local Spark Connect service.
#' @export
spark_connect_service_start <- function(
  version = "4.0",
  scala_version = "2.13",
  python_version = NULL,
  python = NULL,
  include_args = TRUE,
  additional_args = NULL,
  ...
) {
  get_version <- spark_install_find(version = version)
  cmd <- path(get_version$sparkVersionDir, "sbin", "start-connect-server.sh")
  args <- c(
    "--packages",
    glue(
      "org.apache.spark:spark-connect_{scala_version}:{get_version$sparkVersion}"
    ),
    additional_args
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
  if (is.null(python)) {
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

  # Wait briefly to see if there's immediate output or errors
  # Don't use read_all_output() as it blocks until process closes stdout
  # Spark Connect is a long-running service, so we only check initial output
  prs$poll_io(timeout = 2000)  # Wait max 2 seconds

  # Read only what's available, don't wait for EOF
  if (prs$is_alive()) {
    output <- prs$read_output_lines()
    if (length(output) > 0) {
      cli_bullets(c(" " = "{.info {paste(output, collapse = '\n')}}"))
    }
    error <- prs$read_error_lines()
    if (length(error) > 0 && any(nzchar(error))) {
      cli_alert_warning(paste(error, collapse = "\n"))
    }
  } else {
    # Process exited immediately, likely an error
    if (prs$get_exit_status() != 0) {
      error <- prs$read_all_error()
      cli_abort(c("Failed to start Spark Connect service", "x" = error))
    }
  }

  # Store the process for potential cleanup
  assign("spark_connect_process", prs, envir = .GlobalEnv)

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

  # Wait for shutdown command to complete
  prs$wait(timeout = 5000)  # Wait max 5 seconds

  cli_bullets(c(" " = "{.info - Shutdown command sent}"))

  # Clean up stored process reference
  if (exists("spark_connect_process", envir = .GlobalEnv)) {
    rm("spark_connect_process", envir = .GlobalEnv)
  }

  cli_end()
  invisible()
}
