#' @export
deploy <- function(
    appDir = NULL,
    python = NULL,
    version = NULL,
    method = "databricks_connect",
    ...) {
  cli_div(theme = cli_colors())
  check_rstudio <- try(RStudio.Version(), silent = TRUE)
  in_rstudio <- !inherits(check_rstudio, "try-error")
  editor_doc <- NULL
  if (is.null(appDir)) {
    if (interactive() && in_rstudio) {
      editor_doc <- getSourceEditorContext()
      appDir <- dirname(editor_doc$path)
      cli_alert_info("{.header Source:{.emph '{appDir}'}}")
    }
  }

  python <- deploy_find_environment(
    python = python,
    version = version,
    method = method
  )

  print(python)

  # deployApp(
  #   appDir = here::here("doc-subfolder"),
  #   python = "/Users/user/.virtualenvs/r-sparklyr-databricks-14.1/bin/python",
  #   envVars = c("DATABRICKS_HOST", "DATABRICKS_TOKEN"),
  #   lint = FALSE
  # )
  cli_end()
}

deploy_find_environment <- function(
    version = NULL,
    python = NULL,
    method) {
  ret <- NULL
  failed <- NULL
  cli_progress_step(
    msg = "Searching and validating Python path",
    msg_done = "{.header Python:{.emph '{ret}'}}",
    msg_failed = "Environment not found: {.emph '{failed}'}"
  )
  if (is.null(python)) {
    env_name <- use_envname(version = version, method = method)
    if (names(env_name) == "exact") {
      check_conda <- try(conda_python(env_name), silent = TRUE)
      check_virtualenv <- try(virtualenv_python(env_name), silent = TRUE)
      if (!inherits(check_conda, "try-error")) ret <- check_conda
      if (!inherits(check_virtualenv, "try-error")) ret <- check_virtualenv
    }
    if (is.null(ret)) failed <- env_name
  } else {
    validate_python <- file_exists(python)
    if (validate_python) {
      ret <- python
    } else {
      failed <- python
    }
  }
  if (is.null(ret)) cli_progress_done(result = "failed")
  path_expand(ret)
}
