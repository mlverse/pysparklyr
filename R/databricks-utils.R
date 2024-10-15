databricks_host <- function(host = NULL, fail = TRUE) {
  if (!is.null(host)) {
    return(set_names(host, "argument"))
  }
  env_host <- Sys.getenv("DATABRICKS_HOST", unset = NA)
  connect_host <- Sys.getenv("CONNECT_DATABRICKS_HOST", unset = NA)
  if (!is.na(env_host)) {
    host <- set_names(env_host, "environment")
  }
  if (!is.na(connect_host)) {
    host <- set_names(connect_host, "environment_connect")
  }
  if (is.null(host)) {
    if (fail) {
      cli_abort(c(
        paste0(
          "No Host URL was provided, and",
          "the environment variable 'DATABRICKS_HOST' is not set."
        ),
        "Please add your Host to 'DATABRICKS_HOST' inside your .Renviron file."
      ))
    } else {
      host <- ""
    }
  }
  host
}

databricks_token <- function(token = NULL, fail = FALSE) {
  # if token provided, return
  # otherwise, search for token:
  # DATABRICKS_TOKEN > CONNECT_DATABRICKS_TOKEN > .rs.api.getDatabricksToken

  if (!is.null(token)) {
    return(set_names(token, "argument"))
  }
  # Checks the Environment Variable
  if (is.null(token)) {
    env_token <- Sys.getenv("DATABRICKS_TOKEN", unset = NA)
    connect_token <- Sys.getenv("CONNECT_DATABRICKS_TOKEN", unset = NA)
    if (!is.na(env_token)) {
      token <- set_names(env_token, "environment")
    } else {
      if (!is.na(connect_token)) {
        token <- set_names(connect_token, "environment_connect")
      }
    }
  }
  # Checks for OAuth Databricks token inside the RStudio API
  if (is.null(token) && exists(".rs.api.getDatabricksToken")) {
    getDatabricksToken <- get(".rs.api.getDatabricksToken")
    token <- set_names(getDatabricksToken(databricks_host()), "oauth")
  }
  if (is.null(token)) {
    if (fail) {
      rlang::abort(c(
        paste0(
          "No authentication token was identified: \n",
          " - No 'DATABRICKS_TOKEN' environment variable found \n",
          " - Not passed as a function argument"
        ),
        "Please add your Token to 'DATABRICKS_TOKEN' inside your .Renviron file."
      ))
    } else {
      token <- ""
    }
  }
  token
}

databricks_dbr_version_name <- function(cluster_id,
                                        client,
                                        silent = FALSE) {
  bullets <- NULL
  version <- NULL
  cluster_info <- databricks_dbr_info(
    cluster_id = cluster_id,
    client = client,
    silent = silent
  )
  cluster_name <- substr(cluster_info$cluster_name, 1, 100)
  version <- databricks_extract_version(cluster_info)
  cli_progress_done()
  cli_end()
  list(version = version, name = cluster_name)
}

databricks_extract_version <- function(x) {
  sp_version <- x$spark_version
  if (!is.null(sp_version)) {
    sp_sep <- unlist(strsplit(sp_version, "\\."))
    version <- paste0(sp_sep[1], ".", sp_sep[2])
  } else {
    version <- ""
  }
  version
}

databricks_dbr_info <- function(cluster_id,
                                client,
                                silent = FALSE) {
  cli_div(theme = cli_colors())

  if (!silent) {
    cli_progress_step(
      msg = "Retrieving info for cluster:}{.emph '{cluster_id}'",
      msg_done = "{.header Cluster:} {.emph '{cluster_id}'} | {.header DBR: }{.emph '{version}'}",
      msg_failed = "Failed contacting:}{.emph '{cluster_id}'"
    )
  }

  out <- databricks_cluster_get(cluster_id, client)
  if (inherits(out, "try-error")) {
    # sanitized <- sanitize_host(host, silent)
    out <- databricks_cluster_get(cluster_id, client)
  }

  if (inherits(out, "try-error")) {
    cli_div(theme = cli_colors())
    invalid_host <- NULL
    invalid_token <- NULL
    invalid_cluster <- NULL
    invalid_msg <- " <<--- Possibly invalid"
    if (grepl("HTTP 404 Not Found", out)) {
      parse_host <- url_parse(host)
      invalid_host <- invalid_msg
      if (!is.null(parse_host$path)) {
        invalid_host <- glue(
          "<<--- Likely cause, last part in the URL: \"{parse_host$path}\""
        )
      }
    }
    if (grepl("HTTP 401 Unauthorized", out)) {
      invalid_token <- invalid_msg
    }
    if (grepl("HTTP 400 Bad Request", out)) {
      invalid_cluster <- invalid_msg
    }

    if (as.character(substr(out, 1, 26)) == "Error in req_perform(.) : ") {
      out <- substr(out, 27, nchar(out))
    }
    if (!silent) cli_progress_done(result = "failed")
    cli_abort(
      c(
        "{.header Connection with Databricks failed: }\"{trimws(out)}\"",
        "{.class  - Host: {.emph '{host}'}} {invalid_host}",
        "{.class  - Cluster ID: {.emph '{cluster_id}'}} {invalid_cluster}",
        "{.class  - Token: {.emph '<REDACTED>'}} {invalid_token}"
      ),
      call = NULL
    )
    out <- list()
  } else {
    version <- databricks_extract_version(out)
  }
  if (!silent) cli_progress_done()
  cli_end()
  out
}

databricks_dbr_version <- function(cluster_id, client) {
  vn <- databricks_dbr_version_name(
    cluster_id = cluster_id,
    client = client
  )
  vn$version
}

databricks_cluster_get <- function(cluster_id, client) {
  try(
    client$clusters$get(cluster_id = cluster_id)$as_dict(),
    silent = TRUE
  )
}

databricks_dbr_error <- function(error) {
  error_split <- error %>%
    as.character() %>%
    strsplit("\n\t") %>%
    unlist()

  error_start <- substr(error_split, 1, 9)

  status_error <- NULL
  if (any(error_start == "status = ")) {
    status_error <- error_split[error_start == "status = "]
  }

  status_details <- NULL
  if (any(error_start == "details =")) {
    status_details <- error_split[error_start == "details ="]
  }

  status_tip <- NULL
  if(!is.null(status_error)){
    if (grepl("UNAVAILABLE", status_error)) {
      status_tip <- "Possible cause = The cluster is not running, or not accessible"
    }
    if (grepl("FAILED_PRECONDITION", status_error)) {
      status_tip <- "Possible cause = The cluster is initializing. Try again later"
    }
  } else {
    status_error <- error
  }

  rlang::abort(
    c(
      "Spark connection error",
      status_tip,
      status_error,
      status_details
    )
  )
}

# sanitize_host <- function(url, silent = FALSE) {
#   parsed_url <- url_parse(url)
#   new_url <- url_parse("http://localhost")
#   if (is.null(parsed_url$scheme)) {
#     new_url$scheme <- "https"
#     if (!is.null(parsed_url$path) && is.null(parsed_url$hostname)) {
#       new_url$hostname <- parsed_url$path
#     }
#   } else {
#     new_url$scheme <- parsed_url$scheme
#     new_url$hostname <- parsed_url$hostname
#   }
#   ret <- url_build(new_url)
#   if (ret != url && !silent) {
#     cli_div(theme = cli_colors())
#     cli_alert_warning(
#       "{.header Changing host URL to:} {.emph {ret}}"
#     )
#     cli_end()
#   }
#   ret
# }

# from httr2
is_hosted_session <- function () {
  if (nzchar(Sys.getenv("COLAB_RELEASE_TAG"))) {
    return(TRUE)
  }
  Sys.getenv("RSTUDIO_PROGRAM_MODE") == "server" &&
    !grepl("localhost", Sys.getenv("RSTUDIO_HTTP_REFERER"), fixed = TRUE)
}

databricks_desktop_login <- function(host = NULL, profile = NULL) {

  # host takes priority over profile
  if (!is.null(host)) {
    method <- "--host"
    value <- host
  } else if (!is.null(profile)) {
    method <- "--profile"
    value <- profile
  } else {
    # todo rlang error?
    stop("must specifiy `host` or `profile`, neither were set")
  }

  cli_path <- Sys.getenv("DATABRICKS_CLI_PATH", "databricks")
  if (!is_hosted_session() && nchar(Sys.which(cli_path)) != 0) {
    # When on desktop, try using the Databricks CLI for auth.
    output <- suppressWarnings(
      system2(
        cli_path,
        c("auth", "login", method, value),
        stdout = TRUE,
        stderr = TRUE
      )
    )
  }
}
