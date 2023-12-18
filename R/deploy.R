#' @@export
deploy_databricks <- function(
    appDir = NULL,
    lint = FALSE,
    python = NULL,
    version = NULL,
    cluster_id = NULL,
    host = NULL,
    token = NULL,
    ...
  ) {
  if (is.null(version) && !is.null(cluster_id)) {
    version <- databricks_dbr_version(
      cluster_id = cluster_id,
      host = databricks_host(),
      token = databricks_token()
    )
  }
  env_vars <- NULL
  if(!is.null(host)) {
    Sys.setenv("CONNECT_DATABRICKS_HOST" = host)
    env_vars <- "CONNECT_DATABRICKS_HOST"
  } else {
    host <- databricks_host()
    if(names(host) == "environment") {
      env_vars <- "DATABRICKS_HOST"
    }
  }
  if(!is.null(token)) {
    Sys.setenv("CONNECT_DATABRICKS_TOKEN" = token)
    env_vars <- c(env_vars, "CONNECT_DATABRICKS_TOKEN")
  } else {
    token <- databricks_token()
    if(names(token) == "environment") {
      env_vars <-  c(env_vars, "DATABRICKS_TOKEN")
    }
  }
  deploy(
    appDir = appDir, lint = lint,
    python = python,
    version = version,
    method = "databricks_connect",
    envVars = env_vars
  )
}

#' @export
deploy <- function(
    appDir = NULL,
    lint = FALSE,
    envVars = NULL,
    python = NULL,
    version = NULL,
    method = NULL,
    ...) {
  if(is.null(method)) {
    abort("'method' is empty, please provide one")
  }
  cli_div(theme = cli_colors())
  check_rstudio <- try(RStudio.Version(), silent = TRUE)
  in_rstudio <- !inherits(check_rstudio, "try-error")
  editor_doc <- NULL
  if (is.null(appDir)) {
    if (interactive() && in_rstudio) {
      editor_doc <- getSourceEditorContext()
      appDir <- dirname(editor_doc$path)
      cli_alert_info("{.header Source: {.emph '{appDir}'}}")
    }
  }
  python <- deploy_find_environment(
    python = python,
    version = version,
    method = method
  )

  print(envVars)
  # CONNECT_DATABRICKS_HOST
  # CONNECT_DATABRICKS_TOKEN
  # Use them if user pases host and token as arguments

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
    method = "databricks_connect") {
  ret <- NULL
  failed <- NULL
  cli_progress_step(
    msg = "Searching and validating Python path",
    msg_done = "{.header Python:{.emph '{ret}'}}",
    msg_failed = "Environment not found: {.emph '{failed}'}"
  )
  if (is.null(python)) {
    if(!is.null(version)) {
      env_name <- use_envname(
        version = version,
        method = method
      )
      if (names(env_name) == "exact") {
        check_conda <- try(conda_python(env_name), silent = TRUE)
        check_virtualenv <- try(virtualenv_python(env_name), silent = TRUE)
        if (!inherits(check_conda, "try-error")) ret <- check_conda
        if (!inherits(check_virtualenv, "try-error")) ret <- check_virtualenv
      }
    } else {
      py_exe_path <- py_exe()
      if(grepl("r-sparklyr-", py_exe_path)) {
        ret <- py_exe_path
      }
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
