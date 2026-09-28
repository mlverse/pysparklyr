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
  if (missing(master) || is.null(master) || grepl("^local", master)) {
    cli_abort(
      c(
        "A {.code master} is required to connect to Sail",
        " " = "Please provide the address of a running Sail server, e.g. 'sc://localhost:50051'"
      ),
      call = NULL
    )
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
    main_library_version = (versions %||% sail_versions(version))$main_library_version,
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
  conn <- pyspark$sql$SparkSession$builder$remote(master)

  initialize_connection(
    conn = conn,
    master_label = glue("Sail - {master}"),
    con_class = "connect_sail",
    method = method,
    config = config
  )
}

setOldClass(
  c("connect_sail", "pyspark_connection", "spark_connection")
)
