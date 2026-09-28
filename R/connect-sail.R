#' @export
spark_connect_method.spark_method_sail <- function(
  x,
  method,
  master,
  spark_home,
  config = NULL,
  app_name,
  version = NULL,
  hadoop_version,
  extensions,
  scala_version,
  ...
) {
  # `spark_connect()` sets `master` to "local" when it is not provided
  if (missing(master) || is.null(master)) {
    master <- "local"
  }

  # With no `version`, resolve both versions up front, since the environment
  # name needs the Sail version. Otherwise the client version lookup stays lazy
  versions <- NULL
  if (is.null(version)) {
    versions <- sail_versions()
    version <- versions$backend_version
  }

  args <- list(...)
  envname <- use_envname(
    backend = "sail",
    main_library = "pyspark-client",
    backend_version = version,
    main_library_version = (versions %||%
      sail_versions(version))$main_library_version,
    envname = args$envname,
    messages = TRUE,
    match_first = TRUE,
    python_version = args$python_version
  )

  if (is.null(envname)) {
    return(invisible())
  }

  # When creating the session, `pyspark-client` can mistake reticulate's
  # embedded Python for a doctest run, and exit if it finds no SPARK_HOME.
  # Any value avoids that, so keep the user's, or use a temporary one. It is
  # set while Python starts, since Python does not see later changes
  pyspark <- withr::with_envvar(
    new = c("SPARK_HOME" = Sys.getenv("SPARK_HOME", unset = tempdir())),
    import_check("pyspark", envname)
  )

  # A "local" master starts a Sail server inside this R session, on a free
  # port. It stops on `spark_disconnect()`, or when the R session ends
  server <- NULL
  if (grepl("^local", master)) {
    pysail_spark <- import_check("pysail.spark", envname, silent = TRUE)
    server <- pysail_spark$SparkConnectServer(ip = "127.0.0.1", port = 0L)
    server$start(background = TRUE)
    port <- server$listening_address[[2]]
    remote <- glue("sc://localhost:{port}")
  } else {
    remote <- master
  }
  # The URL includes the port, which tells local connections apart, e.g. in
  # the Connections pane
  master_label <- glue("Sail - {remote}")
  conn <- pyspark$sql$SparkSession$builder$remote(remote)

  tryCatch(
    initialize_connection(
      conn = conn,
      master_label = master_label,
      con_class = "connect_sail",
      method = method,
      config = config,
      server = server,
      # Each local connection has its own server, so it needs its own session
      create = !is.null(server)
    ),
    error = function(e) {
      if (!is.null(server)) {
        server$stop()
      }
      stop(e)
    }
  )
}

#' @export
spark_disconnect.connect_sail <- function(sc, ...) {
  # R dispatches here before sparklyr's `spark_disconnect.spark_connection()`,
  # which does the cleanup, such as closing the Connections pane. That method
  # then calls `spark_disconnect()` again, without the `spark_connection`
  # class, so return early to stop the session and server only once
  if (!inherits(sc, "spark_connection")) {
    return(invisible())
  }
  stopped <- try(python_conn(sc)$stop(), silent = TRUE)
  if (inherits(stopped, "try-error")) {
    cli_warn("Could not stop the Sail session")
  }
  if (!is.null(sc$server)) {
    stopped <- try(sc$server$stop(), silent = TRUE)
    if (inherits(stopped, "try-error")) {
      cli_warn("Could not stop the local Sail server")
    }
  }
  NextMethod()
}

setOldClass(
  c("connect_sail", "pyspark_connection", "spark_connection")
)

#' Remove a table from a Sail connection
#'
#' Sail's `DROP TABLE` does not drop temp views, which is what most tables are
#' on Sail, so this method tries `dropTempView()` first.
#' @param conn A Sail connection
#' @param name The name of the table
#' @param ... Not used
#' @param fail_if_missing If `FALSE`, no error is raised when the table does
#'   not exist
#' @returns `TRUE`, invisibly
#' @keywords internal
#' @export
setMethod(
  "dbRemoveTable",
  c("connect_sail", "character"),
  function(conn, name, ..., fail_if_missing = TRUE) {
    # Same check as sparklyr's `dbRemoveTable()`, since the name goes into SQL
    if (grepl("`", name, fixed = TRUE)) {
      cli_abort("Can't escape back tick from string")
    }
    dropped <- python_conn(conn)$catalog$dropTempView(name)
    if (!isTRUE(dropped)) {
      if_exists <- if (fail_if_missing) "" else "IF EXISTS "
      dbSendQuery(conn, paste0("DROP TABLE ", if_exists, "`", name, "`"))
    }
    invisible(TRUE)
  }
)
