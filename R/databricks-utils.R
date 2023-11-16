databricks_dbr_version <- function(cluster_id,
                                host = Sys.getenv("DATABRICKS_HOST"),
                                token = Sys.getenv("DATABRICKS_TOKEN")) {
  cli_div(theme = cli_colors())
  cli_alert_warning(
    "{.header Retrieving version from cluster }{.emph '{cluster_id}'}"
  )
  cli_end()

  cluster_info <- databricks_dbr_info(
    cluster_id = cluster_id,
    host = host,
    token = token
  )

  sp_version <- cluster_info$spark_version

  if (!is.null(sp_version)) {
    sp_sep <- unlist(strsplit(sp_version, "\\."))
    version <- paste0(sp_sep[1], ".", sp_sep[2])
    cli_alert_success("{.header Cluster version: }{.emph '{version}'}")
    cli_end()
  } else {
    version <- ""
  }
  version
}

databricks_dbr_info <- function(cluster_id,
                             host = Sys.getenv("DATABRICKS_HOST"),
                             token = Sys.getenv("DATABRICKS_TOKEN")) {
  out <- databricks_cluster_get(cluster_id, host, token)
  if(inherits(out, "try-error")) {
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
    cli_abort(c(
      invalid_host,
      "{.header Issues connecting to Databricks. Currently using: }",
      "{.header |-- Host: }{.emph '{host}' {invalid_host}}",
      "{.header |-- Cluster ID: }{.emph '{cluster_id}' {invalid_cluster}}",
      "{.header |-- Token: }{.emph '<REDACTED>' {invalid_token}}",
      "{.header Error message:} {.class \"{out}\"}"
    ))
    out <- list()
  }
  out
}

databricks_cluster_get <- function(cluster_id,
                        host = Sys.getenv("DATABRICKS_HOST"),
                        token = Sys.getenv("DATABRICKS_TOKEN")) {
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
      c(
        "{.header Sanitizing {.code Host} value:}\n",
        "{.header * Original:} {.emph {url}}\n",
        "{.header * Using:}    {.emph {ret}}\n",
        "* {.header ",
        "To prevent {.code sparklyr} from changing the Host, set ",
        "{.code host_sanitize = FALSE} in {.code spark_connect()}",
        "}"
      )
    )
    cli_end()
  }
  ret
}
