test_that("Databricks installation works", {
  skip_if_not_databricks()
  local_mocked_bindings(install_as_job = function(...) list(...))

  out <- install_databricks(version = "14.1")
  expect_snapshot(out)

  expect_message(
    install_databricks(
      version = "14.1",
      cluster = Sys.getenv("DATABRICKS_CLUSTER_ID"),
      as_job = FALSE
      ),
    "Will use the value from 'version', and ignoring 'cluster_id'"
  )

  expect_message(
    install_databricks(
      cluster = Sys.getenv("DATABRICKS_CLUSTER_ID"),
      as_job = FALSE
    )
  )

  expect_snapshot(install_databricks(version = "13.1"))
})

test_that("Install as job works", {
  local_mocked_bindings(
    check_rstudio = function(...) TRUE,
    jobRunScript = function(...) invisible(),
    install_environment = function(...) list(...)
    )
  expect_message(
    install_as_job(),
    "Running installation as a RStudio job"
  )
  expect_snapshot(
    install_as_job(as_job = TRUE)
  )
})

test_that("Null version works", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    {
      local_mocked_bindings(py_install = function(...) list(...))
      expect_message(
        install_environment(
          main_library = "pyspark",
          spark_method = "pyspark_connect",
          backend = "pyspark",
          ml_version = "3.5",
          new_env = FALSE,
          python = Sys.which("python")
          ),
        "Retrieving version from PyPi.org"
      )

      expect_error(
        install_environment(
          main_library = "pyspark",
          version = "0.1",
          new_env = FALSE,
          python = Sys.which("python")
        ),
        "Version '0.1' is not valid for 'pyspark'"
      )
    })
})

test_that("installed_components() output properly", {
  expect_message(installed_components())
})

test_that("Can get pypy.org info", {
  info <- py_library_info("databricks.connect", "13.0")
  expect_type(info, "list")
  expect_equal(info$summary, "Databricks Connect Client")

  expect_error(py_library_info("doesnt.exist", ""))
})

test_that("version_prep() outputs what's expected", {
  expect_error(version_prep(""))
  expect_error(version_prep("1"))
  expect_equal(version_prep("1.1"), "1.1")
  expect_equal(version_prep("1.1.1"), "1.1")
  expect_error(version_prep("1.1.1.1"))
})

test_that("Install code is correctly created", {
  expect_snapshot(build_job_code(list(a = 1)))
})

skip("temp")
skip_on_ci()

test_that("Databricks installations work", {
  env_paths <- map(1:3, ~ fs::path(tempdir(), random_table_name("env")))
  baseenv <- "r-sparklyr-databricks"
  version_1 <- "14.0"
  version_2 <- "13.0"
  cluster_id <- Sys.getenv("DATABRICKS_CLUSTER_ID")
  python_path <- Sys.which("python1")

  withr::with_envvar(
    new = c("WORKON_HOME" = env_paths[[1]]),
    {
      install_databricks(
        cluster_id = cluster_id,
        install_ml = FALSE,
        as_job = FALSE,
        python = python_path
      )
      expect_equal(length(find_environments(baseenv)), 1)
    }
  )

  withr::with_envvar(
    new = c("WORKON_HOME" = env_paths[[2]]),
    {
      install_databricks(
        version_1,
        install_ml = FALSE,
        as_job = FALSE,
        python = python_path
      )
      expect_equal(length(find_environments(baseenv)), 1)
    }
  )

  withr::with_envvar(
    new = c("WORKON_HOME" = env_paths[[3]]),
    {
      install_databricks(
        version_1,
        install_ml = FALSE,
        as_job = FALSE,
        python = python_path
      )
      install_databricks(
        version_2,
        install_ml = FALSE,
        as_job = FALSE,
        python = python_path
      )
      install_databricks(
        cluster_id = cluster_id,
        install_ml = FALSE,
        as_job = FALSE,
        python = python_path
      )
      expect_equal(length(find_environments(baseenv)), 3)
    }
  )

  map(env_paths, fs::dir_delete)
})
