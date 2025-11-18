# This is to enable mocked tests, and the fact that rsconnect is
# not being directly imported by this package
rsconnect_accounts <- rsconnect::accounts
rsconnect_deployments <- rsconnect::deployments
rsconnect_deployApp <- rsconnect::deployApp

#' Deploys Databricks backed content to publishing server
#'
#' @description
#'  This is a convenience function that is meant to make it easier for
#' you to publish your Databricks backed content to a publishing server. It is
#' meant to be primarily used with Posit Connect.
#'
#' @param appDir A directory containing an application (e.g. a Shiny app or plumber API)
#' Defaults to NULL. If left NULL, and if called within RStudio, it will attempt
#' to use the folder of the currently opened document within the IDE. If there are
#' no opened documents, or not working in the RStudio IDE, then it will use
#' `getwd()` as the default value.
#' @param python Full path to a python binary for use by `reticulate.` It defaults to NULL.
#' If left NULL, this function will attempt to find a viable local Python
#' environment to replicate using the following hierarchy:
#' 1. `version` - Cluster's DBR version
#' 2. `cluster_id` - Query the cluster to obtain its DBR version
#' 3. If one is loaded in the current R session, it will verify that the Python
#' environment is suited to be used as the one to use
#' @param account The name of the account to use to publish
#' @param server The name of the target server to publish
#' @param lint Lint the project before initiating the project? Default to FALSE.
#' It has been causing issues for this type of content.
#' @param version The Databricks Runtime (DBR) version. Use if `python` is NULL.
#' @param cluster_id The Databricks cluster ID. Use if `python`, and `version` are
#' NULL
#' @param host The Databricks host URL. Defaults to NULL. If left NULL, it will
#' use the environment variable `DATABRICKS_HOST`
#' @param token The Databricks authentication token. Defaults to NULL. If left NULL, it will
#' use the environment variable `DATABRICKS_TOKEN`
#' @param forceGeneratePythonEnvironment If an existing requirements.txt file is found,
#' it will be overwritten when this argument is TRUE.
#' @param confirm Should the user be prompted to confirm that the correct
#' information is being used for deployment? Defaults to `interactive()`
#' @param ... Additional named arguments passed to `rsconnect::deployApp()` function
#' @returns No value is returned to R. Only output to the console.
#' @export
deploy_databricks <- function(
  appDir = NULL,
  python = NULL,
  account = NULL,
  server = NULL,
  lint = FALSE,
  forceGeneratePythonEnvironment = TRUE,
  version = NULL,
  cluster_id = NULL,
  host = NULL,
  token = NULL,
  confirm = interactive(),
  ...
) {
  if (!requireNamespace("rsconnect", quietly = FALSE)) {
    cli_abort(
      paste(
        "The package {.pkg rsconnect} is needed for publication but it is not",
        "installed. Use {.run install.packages(\"rsconnect\")} to install and",
        "then try again."
      )
    )
  }

  cli_div(theme = cli_colors())

  cluster_id <- cluster_id %||% Sys.getenv("DATABRICKS_CLUSTER_ID")

  if (is.null(version) && !is.null(cluster_id)) {
    version <- databricks_dbr_version(
      cluster_id = cluster_id,
      host = databricks_host(host),
      token = databricks_token(token)
    )
  }
  env_vars <- NULL
  env_var_message <- NULL
  var_error <- NULL

  # Host URL
  if (!is.null(host)) {
    Sys.setenv("CONNECT_DATABRICKS_HOST" = host)
    env_vars <- "CONNECT_DATABRICKS_HOST"
  } else {
    env_host_name <- "DATABRICKS_HOST"
    env_host <- Sys.getenv(env_host_name, unset = "")
    if (env_host != "") {
      env_vars <- c(env_vars, env_host_name)
      host <- env_host
    }
  }
  if (!is.null(host)) {
    env_var_message <- c("i" = paste0("{.header Host URL:} ", host))
  } else {
    var_error <- c(" " = paste0(
      "{.header - No host URL was provided or found. Please either set the}",
      " {.emph 'DATABRICKS_HOST'} {.header environment variable,}",
      " {.header or pass the }{.code host} {.header argument.}"
    ))
  }

  # Token
  if (!is.null(token)) {
    Sys.setenv("CONNECT_DATABRICKS_TOKEN" = token)
    env_vars <- c(env_vars, "CONNECT_DATABRICKS_TOKEN")
  } else {
    env_token_name <- "DATABRICKS_TOKEN"
    env_token <- Sys.getenv(env_token_name, unset = "")
    if (env_token != "") {
      env_vars <- c(env_vars, env_token_name)
      token <- env_token
    }
  }
  if (!is.null(token)) {
    env_var_message <- c(
      env_var_message,
      " " = "{.header Token:} '<REDACTED>'"
    )
  } else {
    var_error <- c(var_error, " " = paste0(
      "{.header - No token was provided or found. Please either set the}",
      " {.emph 'DATABRICKS_TOKEN'} {.header environment variable,}",
      " {.header or pass the} {.code token} {.header argument.}"
    ))
  }

  if (!is.null(var_error)) {
    cli_abort(c("Cluster setup errors:", var_error), call = NULL)
  }

  deploy(
    appDir = appDir,
    lint = lint,
    python = python,
    version = version,
    backend = "databricks",
    main_library = "databricks-connect",
    envVars = env_vars,
    env_var_message = env_var_message,
    account = account,
    server = server,
    confirm = confirm,
    ...
  )
}

deploy <- function(
  appDir = NULL,
  account = NULL,
  server = NULL,
  lint = FALSE,
  envVars = NULL,
  python = NULL,
  version = NULL,
  backend = NULL,
  main_library = NULL,
  env_var_message = NULL,
  confirm,
  ...
) {
  if (is.null(backend)) {
    abort("'backend' is empty, please provide one")
  }
  rs_accounts <- rsconnect_accounts()
  accts_msg <- NULL
  if (nrow(rs_accounts) == 0) {
    abort("There are no server accounts setup")
  } else {
    if (is.null(account)) {
      account <- rs_accounts$name[1]
    }
    if (is.null(server)) {
      server <- rs_accounts$server[1]
    }
    if (nrow(rs_accounts > 1)) {
      accts_msg <- "Change 'Posit server'"
    }
  }
  cli_div(theme = cli_colors())
  cli_h1("Starting deployment")
  editor_doc <- NULL
  if (is.null(appDir)) {
    if (check_interactive() && check_rstudio()) {
      editor_doc <- getSourceEditorContext()
      if (!is.null(editor_doc)) {
        appDir <- dirname(editor_doc$path)
      }
    }
  }
  if (is.null(appDir)) {
    appDir <- getwd()
  }
  appDir <- path(appDir)

  cli_alert_info("{.header Source directory: {.emph {appDir}}}")
  python <- deploy_find_environment(
    python = python,
    version = version,
    backend = backend,
    main_library = main_library
  )
  cli_inform(c(
    "i" = "{.header Posit server:} {.emph {server}}",
    " " = "{.header Account name:} {.emph {account}}"
  ))
  if (!is.null(env_var_message)) {
    cli_bullets(env_var_message)
  }
  cli_inform("")
  if (check_interactive() && confirm) {
    cli_inform("{.header Does everything look correct?}")
    choice <- menu(choices = c("Yes", "No", accts_msg))
    if (choice == 2) {
      return(invisible())
    }
    if (choice == 3) {
      chr_accounts <- rs_accounts |>
        transpose() |>
        map_chr(\(.x) glue("Server: {.x$server} | Account: {.x$name}"))
      choice <- menu(title = "Select publishing target:", chr_accounts)
      server <- rs_accounts$server[choice]
      account <- rs_accounts$name[choice]
    }

    req_file <- path(appDir, "requirements.txt")
    prev_deployments <- rsconnect_deployments(appDir)
    if (!file_exists(req_file) && nrow(prev_deployments) == 0 && check_interactive()) {
      cli_inform(c(
        "{.header Would you like to create the 'requirements.txt' file?}",
        "{.class Why consider? This will allow you to skip using `version` or `cluster_id`}"
      ))
      choice <- menu(choices = c("Yes", "No"))
      if (choice == 1) {
        requirements_write(
          destfile = req_file,
          python = python
        )
      }
    }
  }

  rsconnect_deployApp(
    appDir = appDir,
    python = python,
    envVars = envVars,
    server = server,
    account = account,
    lint = FALSE,
    ...
  )
}

deploy_find_environment <- function(
  version = NULL,
  python = NULL,
  backend = NULL,
  main_library = NULL
) {
  ret <- NULL
  failed <- NULL
  env_name <- ""
  exe_py <- py_exe()
  if (is.null(python)) {
    if (!is.null(version)) {
      env_name <- use_envname(
        version = version,
        backend = backend,
        main_library = main_library
      )
      if (names(env_name) == "exact") {
        check_conda <- try(conda_python(env_name), silent = TRUE)
        check_virtualenv <- try(virtualenv_python(env_name), silent = TRUE)
        if (!inherits(check_conda, "try-error")) ret <- check_conda
        if (!inherits(check_virtualenv, "try-error")) ret <- check_virtualenv
      }
      if (is.null(ret)) failed <- env_name
    } else {
      if (grepl("r-sparklyr-", exe_py)) {
        ret <- exe_py
      } else {
        failed <- "Please pass a 'version' or a 'cluster_id'"
      }
    }
  } else {
    validate_python <- file_exists(python)
    if (validate_python) {
      ret <- python
    } else {
      failed <- python
    }
  }
  if (is.null(ret)) {
    if (is.null(exe_py)) {
      cli_abort("No Python environment could be found")
    } else {
      ret <- exe_py
    }
  } else {
    ret <- path_expand(ret)
  }
  cli_bullets(c("i" = "{.header Python:} {ret}"))
  ret
}
