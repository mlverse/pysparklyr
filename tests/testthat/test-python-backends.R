# Locks in the environment names and package lists that each back-end gets,
# so changes to `use_envname()`, `python_requirements()`, and
# `install_environment()` do not quietly change them. PyPI is mocked so new
# releases do not change the snapshots.

test_mock_library_info <- function(
  library_name,
  library_version = NULL,
  verbose = TRUE,
  fail = TRUE,
  timeout = 2
) {
  latest <- list(
    "pyspark" = "4.2.0",
    "databricks-connect" = "17.3.0",
    "databricks.connect" = "17.3.0",
    "snowflake-snowpark-python" = "1.40.0"
  )
  requires_dist <- list(
    "pyspark" = c(
      "py4j==0.10.9.7",
      "numpy>=1.21; extra == \"ml\"",
      "pandas>=1.4.4; extra == \"connect\"",
      "pyarrow>=11.0.0; extra == \"connect\""
    ),
    "databricks-connect" = c(
      "databricks-sdk>=0.29.0",
      "googleapis-common-protos>=1.56.4",
      "grpcio>=1.59.3",
      "pandas>=1.0.5",
      "pyarrow>=4.0.0"
    ),
    "snowflake-snowpark-python" = c(
      "setuptools>=40.6.0",
      "snowflake-connector-python>=3.12.0",
      "pandas; extra == \"pandas\""
    )
  )
  requires_dist[["databricks.connect"]] <- requires_dist[["databricks-connect"]]
  if (is.null(library_version) || library_version == "latest") {
    version <- latest[[library_name]]
  } else {
    parts <- strsplit(library_version, "\\.")[[1]]
    version <- paste0(c(parts, rep("0", 3 - length(parts))), collapse = ".")
  }
  list(
    name = library_name,
    version = version,
    requires_python = ">=3.10",
    requires_dist = requires_dist[[library_name]]
  )
}

test_backends <- list(
  pyspark = list(backend = "pyspark", main_library = "pyspark"),
  databricks = list(
    backend = "databricks",
    main_library = "databricks.connect"
  ),
  snowflake = list(
    backend = "snowflake",
    main_library = "snowflake-snowpark-python"
  )
)

test_that("Environment names per back-end", {
  local_mocked_bindings(
    python_library_info = test_mock_library_info,
    find_environments = function(x) character()
  )
  cases <- list(
    list("pyspark", "3.5"),
    list("pyspark", "3.5.1"),
    list("pyspark", NULL),
    list("pyspark", "100.0"),
    list("databricks", "16.1"),
    list("databricks", NULL),
    list("snowflake", "latest"),
    list("snowflake", "1.20")
  )
  out <- lapply(cases, function(x) {
    be <- test_backends[[x[[1]]]]
    use_envname(
      backend = be$backend,
      main_library = be$main_library,
      backend_version = x[[2]],
      messages = FALSE,
      ignore_reticulate_python = TRUE
    )
  })
  expect_snapshot(out)
})

test_that("Environment names when other environments exist", {
  local_mocked_bindings(
    python_library_info = test_mock_library_info,
    find_environments = function(x) paste0(x, "3.4")
  )
  expect_snapshot({
    use_envname(
      backend = "pyspark",
      main_library = "pyspark",
      backend_version = "3.5",
      messages = TRUE,
      match_first = TRUE,
      ignore_reticulate_python = TRUE
    )
    use_envname(
      backend = "pyspark",
      main_library = "pyspark",
      backend_version = "4.2",
      messages = TRUE,
      match_first = TRUE,
      ignore_reticulate_python = TRUE
    )
    use_envname(
      backend = "pyspark",
      main_library = "pyspark",
      backend_version = "3.4",
      messages = TRUE,
      match_first = TRUE,
      ignore_reticulate_python = TRUE
    )
  })
})

test_that("Environment names when PyPI cannot be reached", {
  local_mocked_bindings(
    python_library_info = function(...) NULL,
    find_environments = function(x) paste0(x, "3.4")
  )
  expect_snapshot(
    use_envname(
      backend = "pyspark",
      main_library = "pyspark",
      backend_version = "3.5",
      messages = FALSE,
      match_first = TRUE,
      ignore_reticulate_python = TRUE
    )
  )
})

test_that("Python requirements per back-end", {
  local_mocked_bindings(python_library_info = test_mock_library_info)
  cases <- list(
    list("pyspark", "3.5"),
    list("databricks", "16.1"),
    list("databricks", "14.1"),
    list("snowflake", "1.20")
  )
  out <- lapply(cases, function(x) {
    be <- test_backends[[x[[1]]]]
    python_requirements(
      backend = be$backend,
      main_library = be$main_library,
      backend_version = x[[2]]
    )
  })
  expect_snapshot(out)
  expect_snapshot(
    python_requirements(
      backend = "pyspark",
      main_library = "pyspark",
      backend_version = "3.5",
      install_ml = TRUE,
      add_torch = TRUE
    )
  )
})

test_that("Python requirements when PyPI cannot be reached", {
  local_mocked_bindings(python_library_info = function(...) NULL)
  expect_snapshot(
    python_requirements(
      backend = "pyspark",
      main_library = "pyspark",
      backend_version = "3.5",
      python_version = "3.10"
    )
  )
})

test_that("Installed packages per back-end", {
  local_mocked_bindings(
    python_library_info = test_mock_library_info,
    find_environments = function(x) character(),
    py_install = function(...) list(...)
  )
  install <- function(...) {
    x <- install_environment(new_env = FALSE, ...)
    x[c("packages", "envname", "python_version")]
  }
  expect_snapshot({
    install(
      main_library = "pyspark",
      spark_method = "pyspark_connect",
      backend = "pyspark",
      ml_version = "3.5",
      backend_version = "3.5"
    )
    install(
      main_library = "pyspark",
      spark_method = "pyspark_connect",
      backend = "pyspark",
      ml_version = "3.5",
      backend_version = NULL,
      install_ml = TRUE
    )
    install(
      main_library = "databricks-connect",
      spark_method = "databricks_connect",
      backend = "databricks",
      ml_version = "14.1",
      backend_version = "16.1"
    )
  })
})

test_that("Installed packages when PyPI cannot be reached", {
  local_mocked_bindings(
    python_library_info = function(...) NULL,
    find_environments = function(x) character(),
    py_install = function(...) list(...)
  )
  x <- install_environment(
    main_library = "databricks-connect",
    spark_method = "databricks_connect",
    backend = "databricks",
    ml_version = "14.1",
    backend_version = "16.1",
    python_version = "3.12",
    new_env = FALSE
  )
  expect_snapshot(x[c("packages", "envname", "python_version")])
})

test_that("Install job code per back-end", {
  local_mocked_bindings(
    check_rstudio = function(...) TRUE,
    jobRunScript = function(path, name) cat(name, readLines(path), sep = "\n")
  )
  expect_snapshot({
    install_pyspark(version = "3.5")
    install_databricks(version = "16.1")
  })
})
