normalize_databricks_host <- function(host) {
  if (!nzchar(host)) return(host)
  if (!grepl("^https?://", host)) host <- paste0("https://", host)
  # Drop path, query, and fragment — keep scheme + authority only.
  sub("(https?://[^/?#]+).*", "\\1", host)
}

databricks_sdk_config <- function(
  sdk,
  host,
  token = NULL,
  profile = NULL,
  cluster_id = NULL,
  serverless = FALSE,
  workspace = NULL
) {
  # Posit Connect credentials take priority — the SDK doesn't know about these.
  if (!is.null(workspace)) {
    connect_token <- connectcreds_databricks_token(workspace)
    if (!is.null(connect_token)) {
      token <- connect_token
    }
  }

  sdk_args <- list()
  if (!is.null(profile)) sdk_args$profile <- profile
  if (!is.null(token) && nzchar(token)) {
    sdk_args$host <- host
    sdk_args$token <- token
  } else if (nzchar(host)) {
    sdk_args$host <- host
  }

  if (serverless) {
    sdk_args$serverless_compute_id <- "auto"
  } else if (!is.null(cluster_id) && nzchar(cluster_id)) {
    sdk_args$cluster_id <- cluster_id
  }

  do.call(sdk$core$Config, sdk_args)
}

connectcreds_databricks_token <- function(workspace) {
  workspace <- normalize_databricks_host(workspace)
  if (has_viewer_token(workspace)) {
    return(connect_viewer_token(workspace)$access_token)
  }
  if (has_service_account_token(workspace)) {
    return(connect_service_account_token(workspace)$access_token)
  }
  NULL
}

databricks_dbr_version_name <- function(
  cluster_id,
  client = NULL,
  host = NULL,
  token = NULL,
  silent = FALSE
) {
  bullets <- NULL
  version <- NULL
  cluster_info <- databricks_dbr_info(
    cluster_id = cluster_id,
    client = client,
    host = host,
    token = token,
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

databricks_dbr_info <- function(
  cluster_id,
  client = NULL,
  host = NULL,
  token = NULL,
  silent = FALSE
) {
  cli_div(theme = cli_colors())

  if (!silent) {
    cli_progress_step(
      msg = "Retrieving info for cluster:}{.emph '{cluster_id}'",
      msg_done = "{.header Cluster:} {.emph '{cluster_id}'} | {.header DBR: }{.emph '{version}'}",
      msg_failed = "Failed contacting:}{.emph '{cluster_id}'"
    )
  }

  out <- databricks_cluster_get(cluster_id, client, host, token)

  if (inherits(out, "try-error")) {
    cli_div(theme = cli_colors())
    invalid_host <- NULL
    invalid_token <- NULL
    invalid_cluster <- NULL
    invalid_msg <- " <<--- Possibly invalid"
    if (grepl("HTTP 404 Not Found", out)) {
      parse_host <- url_parse(client$config$host)
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
    if (!silent) {
      cli_progress_done(result = "failed")
    }
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
  if (!silent) {
    cli_progress_done()
  }
  cli_end()
  out
}

databricks_dbr_version <- function(
  cluster_id,
  client = NULL,
  host = NULL,
  token = NULL
) {
  vn <- databricks_dbr_version_name(
    cluster_id = cluster_id,
    client = client,
    host = host,
    token = token
  )
  vn$version
}

databricks_cluster_get <- function(
  cluster_id,
  client = NULL,
  host = NULL,
  token = NULL
) {
  if (!is.null(client)) {
    try(
      client$clusters$get(cluster_id = cluster_id)$as_dict(),
      silent = TRUE
    )
  } else {
    try(
      paste0(
        host,
        "/api/2.0/clusters/get"
      ) |>
        request() |>
        req_auth_bearer_token(token) |>
        req_body_json(list(cluster_id = cluster_id)) |>
        req_perform() |>
        resp_body_json(),
      silent = TRUE
    )
  }
}

databricks_dbr_error <- function(error) {
  error_split <- error |>
    as.character() |>
    strsplit("\n\t") |>
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
  if (!is.null(status_error)) {
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

databricks_dbr_python <- function(version) {
  if (version >= "16.0") {
    "3.12"
  } else if (version >= "15.0") {
    "3.11"
  } else {
    "3.10"
  }
}

# https://docs.databricks.com/aws/en/release-notes/serverless#supported-spark-configuration-parameters
allowed_serverless_configs <- function() {
  c(
    "spark.sql.legacy.timeParserPolicy",
    "spark.sql.session.timeZone",
    "spark.sql.shuffle.partitions",
    "spark.sql.ansi.enabled"
  )
}
