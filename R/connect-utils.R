initialize_connection <- function(
  conn,
  master_label,
  con_class,
  cluster_id = NULL,
  serverless = FALSE,
  method = NULL,
  config = NULL,
  misc = NULL,
  quote = NULL
) {
  warnings <- import("warnings")
  warnings$filterwarnings(
    "ignore",
    message = "is_datetime64tz_dtype is deprecated",
    module = "pyspark"
  )
  warnings$filterwarnings(
    "ignore",
    message = "is_categorical_dtype is deprecated",
    module = "pyspark"
  )
  warnings$filterwarnings(
    "ignore",
    message = "'SparkSession' object has no attribute 'setLocalProperty'",
    module = "pyspark"
  )
  warnings$filterwarnings(
    "ignore",
    message = "Index.format is deprecated and will be removed in a future version"
  )

  session <- conn$getOrCreate()
  get_version <- try(session$version, silent = TRUE)
  if (inherits(get_version, "try-error")) databricks_dbr_error(get_version)

  if (!is.null(config)) {
    # remove sparklyr default configs (at least for now)
    config <- list_diff(config, sparklyr::spark_config())

    # remove any other sparklyr configs
    config <- config[!grepl("^sparklyr", names(config))]

    # add pyspark configs if not on serverless
    # drop spark sql configs that are unsupported on serverless
    if (!serverless) {
      config <- c(config, pyspark_config())
    } else {
      # ensure only `spark.sql.<...>` configs are considered
      sql_configs <- names(config)[grepl("^spark.sql", names(config))]
      allowed_confs <- sql_configs %in% allowed_serverless_configs()

      # drop configs that aren't supported
      dropped <- sql_configs[!allowed_confs]

      if (length(dropped) > 0) {
        cli::cli_alert_warning(
          text = "Unsupported configs on serverless were dropped:"
        )
        cli::cli_li(paste0("{.envvar ", dropped, "}"))
        cli::cli_end()
      }
      config <- config[!names(config) %in% dropped]
    }

    iwalk(config, function(x, y) session$conf$set(y, x))
  }

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
      serverless = serverless,
      misc = misc,
      quote = quote,
      con = structure(list(), class = c("spark_connection", "DBIConnection"))
    ),
    class = c(
      con_class,
      "pyspark_connection",
      "spark_connection",
      "DBIConnection"
    )
  )

  sc
}

python_conn <- function(x) {
  py_object <- "python.builtin.object"
  ret <- NULL
  if (inherits(x$state$spark_context, py_object)) {
    ret <- x$state$spark_context
  }
  if (is.null(ret) && inherits(x[[1]]$session$sparkSession, py_object)) {
    ret <- x[[1]]$session$sparkSession
  }
  if (is.null(ret)) {
    cli_abort("Could not match Python Connection to: {class(x)}")
  }
  ret
}

build_user_agent <- function() {
  product <- NULL
  in_rstudio <- FALSE
  in_connect <- FALSE

  env_var <- Sys.getenv("SPARK_CONNECT_USER_AGENT", unset = NA)
  if (!is.na(env_var)) {
    return(env_var)
  }

  if (current_product_connect()) {
    product <- "posit-connect"
  }

  if (is.null(product)) {
    pr <- NULL
    if (check_rstudio()) {
      rstudio_version <- int_rstudio_version()
      edition <- rstudio_version$edition
      mode <- rstudio_version$mode
      version <- rstudio_version$long_version
      pr <- "rstudio"
      if (length(edition) == 0) edition <- ""

      if (length(mode) == 0) mode <- ""
      if (edition == "Professional") {
        if (mode == "server") {
          pr <- "workbench-rstudio"
        } else {
          pr <- "rstudio-pro"
        }
      }
      if (Sys.getenv("R_CONFIG_ACTIVE") == "rstudio_cloud") {
        pr <- "cloud-rstudio"
      }
    }
    if (Sys.getenv("POSITRON", unset = "0") == "1") {
      pr <- "positron"
      version <- Sys.getenv("POSITRON_VERSION", unset = NA)
    }
    if (!is.null(pr)) {
      product <- glue("posit-{pr}/{version}")
    }
  }

  glue(
    "sparklyr/{packageVersion('sparklyr')} {product}",
    .null = NULL
  )
}

int_rstudio_version <- function() {
  out <- try(RStudio.Version(), silent = TRUE)
  if (!inherits(out, "try-error")) {
    return(out)
  }
  return(NULL)
}

connection_label <- function(x) {
  x <- x[[1]]
  ret <- "Connection"
  method <- NULL
  con <- spark_connection(x)
  if (is.null(con)) {
    method <- x
  } else {
    method <- con$method
  }
  if (!is.null(method)) {
    if (method == "spark_connect" | method == "pyspark") {
      ret <- "Spark Connect"
    }
    if (method == "databricks_connect" | method == "databricks") {
      ret <- "Databricks Connect"
    }
  }
  ret
}

#' Read Spark configuration
#' @returns A list object with the initial configuration that will be used for
#' the Connect session.
#' @export
pyspark_config <- function() {
  list(
    "spark.sql.session.localRelationCacheThreshold" = 1048576L,
    "spark.sql.execution.arrow.pyspark.enabled" = "true",
    "spark.sql.execution.arrow.sparkr.enabled" = "true"
  )
}
