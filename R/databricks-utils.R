databricks_host <- function(host = NULL, fail = TRUE) {
  host <- host %||% Sys.getenv("DATABRICKS_HOST", unset = NA)
  if(is.null(host) | is.na(host)) {
    if(fail) {
      cli_abort(c(
        paste0("No Host URL was provided, and",
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
  name <- "argument"
  # Checks for OAuth Databricks token inside the RStudio API
  if (is.null(token) && exists(".rs.api.getDatabricksToken")) {
    getDatabricksToken <- get(".rs.api.getDatabricksToken")
    name <- "oauth"
    token <- getDatabricksToken(databricks_host())
  }
  # Checks the Environment Variable
  if(is.null(token)) {
    env_token <- Sys.getenv("DATABRICKS_TOKEN", unset = NA)
    if(!is.na(env_token)) {
      name <- "environment"
      token <- env_token
    }
  }
  if(is.null(token)) {
    if(fail) {

      rlang::abort(c(
        paste0(
          "No authentication token was identified: \n",
          " - No 'DATABRICKS_TOKEN' environment variable found \n",
          " - No Databricks OAuth token found \n",
          " - Not passed as a function argument"
          ),
        "Please add your Token to 'DATABRICKS_TOKEN' inside your .Renviron file."
      ))
    } else {
      name <- NULL
      token <- ""
    }
  }
  set_names(token, name)
}

databricks_dbr_version <- function(cluster_id,
                                   host = NULL,
                                   token = NULL) {
  cli_div(theme = cli_colors())
  cli_alert_warning(
    "{.header Retrieving version from cluster }{.emph '{cluster_id}'}"
  )
  cluster_info <- databricks_dbr_info(
    cluster_id = cluster_id,
    host = host,
    token = token
  )
  sp_version <- cluster_info$spark_version
  if (!is.null(sp_version)) {
    sp_sep <- unlist(strsplit(sp_version, "\\."))
    version <- paste0(sp_sep[1], ".", sp_sep[2])
    cli_bullets(c(
      " " = "{.class Cluster version: }{.emph '{version}'}"
      ))
  } else {
    version <- ""
  }
  cli_end()
  version
}

databricks_dbr_info <- function(cluster_id,
                                host = NULL,
                                token = NULL) {
  out <- databricks_cluster_get(cluster_id, host, token)
  if (inherits(out, "try-error")) {
    out <- databricks_cluster_get(cluster_id, sanitize_host(host), token)
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

    if(as.character(substr(out, 1, 26)) == "Error in req_perform(.) : ") {
      out <- substr(out, 27, nchar(out))
    }
    cli_abort(c(
      "{.header Connection with Databricks failed: }\"{trimws(out)}\"",
      "{.class  - Host: {.emph '{host}'}} {invalid_host}",
      "{.class  - Cluster ID: {.emph '{cluster_id}'}} {invalid_cluster}",
      "{.class  - Token: {.emph '<REDACTED>'}} {invalid_token}"
    ),
    call = NULL)
    out <- list()
  }
  out
}

databricks_cluster_get <- function(cluster_id,
                                   host = NULL,
                                   token = NULL) {
  try(
    paste0(
      host,
      "/api/2.0/clusters/get"
    ) %>%
      request() %>%
      req_auth_bearer_token(token) %>%
      req_body_json(list(cluster_id = cluster_id)) %>%
      req_perform() %>%
      resp_body_json(),
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
  if (grepl("UNAVAILABLE", status_error)) {
    status_tip <- "Possible cause = The cluster is not running, or not accessible"
  }
  if (grepl("FAILED_PRECONDITION", status_error)) {
    status_tip <- "Possible cause = The cluster is initializing. Try again later"
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

sanitize_host <- function(url) {
  parsed_url <- url_parse(url)
  new_url <- url_parse("http://localhost")
  if (is.null(parsed_url$scheme)) {
    new_url$scheme <- "https"
    if (!is.null(parsed_url$path) && is.null(parsed_url$hostname)) {
      new_url$hostname <- parsed_url$path
    }
  } else {
    new_url$scheme <- parsed_url$scheme
    new_url$hostname <- parsed_url$hostname
  }
  ret <- url_build(new_url)
  if (ret != url) {
    cli_div(theme = cli_colors())
    cli_alert_warning(
      "{.header Sanitizing Databricks Host ({.code master}) entry:}"
      )
    cli_bullets(c(
      " " = "{.header Original: {.emph {url}}}",
      " " = "{.header Using:}    {.emph {ret}}",
      " " = paste0(
        "{.class Set {.code host_sanitize = FALSE} ",
        "in {.code spark_connect()} to avoid this change}"
        )
    ))

    cli_end()
  }
  ret
}
