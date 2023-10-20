#' @export
spark_connect_method.spark_method_spark_connect <- function(
    x,
    method,
    master = NULL,
    spark_home,
    config,
    app_name,
    version,
    packages,
    extensions,
    scala_version,
    ...) {
  py_spark_connect(
    master = master,
    method = method,
    config = config,
    spark_version = version,
    ... = ...
  )
}

#' @export
spark_connect_method.spark_method_databricks_connect <- function(
    x,
    method,
    master = Sys.getenv("DATABRICKS_HOST"),
    spark_home,
    config,
    app_name,
    version,
    packages,
    extensions,
    scala_version,
    ...) {
  py_spark_connect(master = master, method = method, config = config, ...)
}

py_spark_connect <- function(master,
                             token = Sys.getenv("DATABRICKS_TOKEN"),
                             cluster_id = NULL,
                             method = "",
                             envname = NULL,
                             spark_version = NULL,
                             dbr_version = NULL,
                             config = list()) {
  method <- method[[1]]

  conn <- NULL

  if (method == "spark_connect") {
    if (is.null(envname)) {
      env_base <- "r-sparklyr-pyspark-"
      envs <- find_environments(env_base)
      if (length(envs) == 0) {
        cli_div(theme = cli_colors())
        cli_abort(c(
          paste0(
            "{.header No environment name provided, and }",
            "{.header  no environment was automatically identified.}"
          ),
          "Run {.run pysparklyr::install_pyspark()} to install."
        ), call = NULL)
        cli_end()
      } else {
        if (!is.null(spark_version)) {
          sp_version <- version_prep(spark_version)
          envname <- glue("{env_base}{sp_version}")
          matched <- envs[envs == envname]
          if (length(matched) == 0) {
            envname <- envs[[1]]
            cli_div(theme = cli_colors())
            cli_alert_warning(paste(
              "{.header A Python environment with a matching version was not found}",
              "* {.header Will attempt connecting using }{.emph '{envname}'}",
              paste0(
                "* {.header To install the proper Python environment use:}",
                " {.run pysparklyr::install_pyspark(version = \"{sp_version}\")}"
              ),
              sep = "\n"
            ))
            cli_end()
          } else {
            envname <- matched
          }
        } else {
          envname <- envs[[1]]
        }
      }
    }

    pyspark <- import_check("pyspark", envname)
    pyspark_sql <- pyspark$sql
    conn <- pyspark_sql$SparkSession$builder$remote(master)
    con_class <- "connect_spark"
    master_label <- glue("Spark Connect - {master}")
  }

  if (method == "databricks_connect") {
    reticulate_python <- Sys.getenv("RETICULATE_PYTHON", unset = NA)
    cluster_id <- cluster_id %||% Sys.getenv("DATABRICKS_CLUSTER_ID")
    master <- master %||% Sys.getenv("DATABRICKS_HOST")

    if (is.na(reticulate_python)) {
      if (is.null(dbr_version)) {
        dbr <- cluster_dbr_version(
          cluster_id = cluster_id,
          host = master,
          token = token
        )
      } else {
        dbr <- version_prep(dbr_version)
      }

      env_base <- "r-sparklyr-databricks-"
      envname <- glue("{env_base}{dbr}")
      envs <- find_environments(env_base)
      matched <- envs[envs == envname]
      if (length(matched) == 0) {
        envname <- envs[[1]]
        cli_div(theme = cli_colors())
        cli_alert_warning(paste(
          "{.header A Python environment with a matching version was not found}",
          "* {.header Will attempt connecting using }{.emph '{envname}'}",
          paste0(
            "* {.header To install the proper Python environment use:}",
            " {.run pysparklyr::install_databricks(version = \"{dbr}\")}"
          ),
          sep = "\n"
        ))
        cli_end()
      }
    } else {
      if (!is.na(reticulate_python)) {
        msg <- paste(
          "{.header Using the Python environment defined in the}",
          "{.emph 'RETICULATE_PYTHON' }{.header environment variable}",
          "{.class ({py_exe()})}"
        )
        cli_div(theme = cli_colors())
        cli_alert_warning(msg)
        cli_end()
        envname <- reticulate_python
      }
    }

    db <- import_check("databricks.connect", envname)
    remote <- db$DatabricksSession$builder$remote(
      host = master,
      token = token,
      cluster_id = cluster_id
    )

    user_agent <- build_user_agent()

    conn <- remote$userAgent(user_agent)
    con_class <- "connect_databricks"

    cluster_info <- cluster_dbr_info(cluster_id, master, token)

    cluster_name <- substr(cluster_info$cluster_name, 1, 100)

    master_label <- glue("{cluster_name} ({cluster_id})")
  }

  session <- conn$getOrCreate() # pyspark.sql.connect.session.SparkSession
  get_version <- try(session$version, silent = TRUE)
  if (inherits(get_version, "try-error")) cluster_dbr_error(get_version)
  session$conf$set("spark.sql.session.localRelationCacheThreshold", 1048576L)

  # do we need this `spark_context` object?
  spark_context <- list(spark_context = session)

  # browser()
  sc <- structure(
    list(
      master = master_label,
      cluster_id = cluster_id,
      config = config,
      method = method,
      session = session,
      state = spark_context,
      con = structure(list(), class = c("spark_connection", "DBIConnection"))
    ),
    class = c(con_class, "pyspark_connection", "spark_connection", "DBIConnection")
  )

  sc
}
setOldClass(
  c("Hive", "spark_connection")
)


setOldClass(
  c("connect_spark", "pyspark_connection", "spark_connection")
)

setOldClass(
  c("connect_databricks", "pyspark_connection", "spark_connection")
)

python_conn <- function(x) {
  x$state$spark_context
}

build_user_agent <- function() {
  product <- NULL
  in_rstudio <- FALSE
  in_connect <- FALSE

  env_var <- Sys.getenv("SPARK_CONNECT_USER_AGENT", unset = NA)
  if (!is.na(env_var)) {
    return(env_var)
  }

  if (Sys.getenv("RSTUDIO_PRODUCT") == "CONNECT") {
    product <- "posit-connect"
  }

  if (is.null(product)) {
    check_rstudio <- try(RStudio.Version(), silent = TRUE)
    if (!inherits(check_rstudio, "try-error")) {
      prod <- "rstudio"

      edition <- check_rstudio$edition
      if (length(edition) == 0) edition <- ""

      mod <- check_rstudio$mode
      if (length(mod) == 0) mod <- ""

      if (edition == "Professional") {
        if (mod == "server") {
          prod <- "workbench-rstudio"
        } else {
          prod <- "rstudio-pro"
        }
      }

      if (Sys.getenv("R_CONFIG_ACTIVE") == "rstudio_cloud") {
        prod <- "cloud-rstudio"
      }

      product <- glue("posit-{prod}/{check_rstudio$long_version}")
    }
  }

  glue(
    paste(
      "sparklyr/{packageVersion('sparklyr')}",
      product
    )
  )
}


cluster_dbr_version <- function(cluster_id,
                                host = Sys.getenv("DATABRICKS_HOST"),
                                token = Sys.getenv("DATABRICKS_TOKEN")) {
  cli_div(theme = cli_colors())
  cli_alert_warning(
    "{.header Retrieving version from cluster }{.emph '{cluster_id}'}"
  )

  cluster_info <- cluster_dbr_info(
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

cluster_dbr_info <- function(cluster_id,
                             host = Sys.getenv("DATABRICKS_HOST"),
                             token = Sys.getenv("DATABRICKS_TOKEN")) {
  out <- try(
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


find_environments <- function(x) {
  conda_names <- tryCatch(conda_list()$name, error = function(e) character())
  ve_names <- virtualenv_list()
  all_names <- c(ve_names, conda_names)
  sub_names <- substr(all_names, 1, nchar(x))
  matched <- all_names[sub_names == x]
  sorted <- sort(matched, decreasing = TRUE)
  sorted
}

cluster_dbr_error <- function(error) {
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

connection_label <- function(x) {
  ret <- "Connection"
  con <- spark_connection(x)
  if(!is.null(con)) {
    if(con$method == "spark_connect") ret <- "Spark Connect"
    if(con$method == "databricks_connect") ret <- "Databricks Connect"
  }
  ret
}
