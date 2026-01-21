new_env <- use_new_test_env()
test_that("It checks with PyPi if library version is NULL", {
  withr::with_envvar(
    new = c("WORKON_HOME" = new_env),
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
    }
  )
})

test_that("Adds the ML libraries when prompted", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_new_test_env()),
    {
      local_mocked_bindings(py_install = function(...) list(...))
      x <- install_environment(
        main_library = "pyspark",
        spark_method = "pyspark_connect",
        backend = "pyspark",
        version = "3.5",
        ml_version = "3.5",
        new_env = FALSE,
        python = Sys.which("python"),
        # Arg(s) being tested
        install_ml = TRUE
      )
      x <- x[names(x) != "python_version"]
      expect_snapshot(x)
    }
  )
})

test_that("Fails when passing an invalid library version", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_new_test_env()),
    {
      local_mocked_bindings(py_install = function(...) list(...))
      expect_error(
        install_environment(
          main_library = "pyspark",
          new_env = FALSE,
          python = Sys.which("python"),
          # Arg(s) being tested
          version = "0.1",
        ),
        "Version '0.1' is not valid for 'pyspark'"
      )
    }
  )
})


test_that("install_as_job() is able to run", {
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

test_that("Installation runs even if no response from PyPi", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_new_test_env()),
    {
      local_mocked_bindings(
        py_install = function(...) list(...),
        python_library_info = function(...) NULL
      )
      x <- install_environment(
        main_library = "pyspark",
        spark_method = "pyspark_connect",
        backend = "pyspark",
        version = "3.5",
        ml_version = "3.5",
        new_env = FALSE,
        python = Sys.which("python")
      )
      x <- x[names(x) != "python_version"]
      expect_snapshot(x)
    }
  )
})

test_that("Fails when no library version is provided, and nothing comes back from PyPi", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_new_test_env()),
    {
      local_mocked_bindings(
        py_install = function(...) list(...),
        python_library_info = function(...) NULL
      )
      expect_error(
        install_environment(
          main_library = "pyspark",
          spark_method = "pyspark_connect",
          backend = "pyspark",
          ml_version = "3.5",
          new_env = FALSE,
          python = Sys.which("python")
        ),
        "No `version` provided, and none could be found"
      )
    }
  )
})

test_that("Fails when non-existent Python version is used", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_new_test_env()),
    {
      local_mocked_bindings(
        virtualenv_starter = function(...) {
          return(NULL)
        }
      )
      expect_error(
        install_environment(
          main_library = "pyspark",
          spark_method = "pyspark_connect",
          backend = "pyspark",
          version = "3.5",
          ml_version = "3.5",
          python = Sys.which("python"),
          # Arg(s) being tested
          new_env = TRUE,
          python_version = "10.1"
        ),
        "Python version '10.1' or higher is required by some libraries."
      )
    }
  )
})

test_that("Can get pypy.org info", {
  info <- python_library_info("databricks.connect", "13.0")
  expect_type(info, "list")
  expect_equal(info$summary, "Databricks Connect Client")

  expect_error(python_library_info("doesnt.exist", ""))
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

test_that("Databricks installation works", {
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

  vcr::local_cassette("databricks-install")

  expect_message(
    withr::with_envvar(
      new = c(
        "DATABRICKS_HOST" = use_test_db_host(),
        "DATABRICKS_TOKEN" = databricks_token()
      ),
      {
        install_databricks(
          cluster = use_test_db_cluster(),
          as_job = FALSE
        )
      }
    )
  )
  expect_snapshot(install_databricks(version = "13.1"))
})

skip_on_ci()

test_that("Databricks installations work", {
  skip("Avoids multiple installations")
  env_paths <- map(1:3, \(.x) fs::path(tempdir(), random_table_name("env")))
  baseenv <- "r-sparklyr-databricks"
  version_1 <- "14.3"
  version_2 <- "13.3"
  cluster_id <- Sys.getenv("DATABRICKS_CLUSTER_ID")
  python_path <- Sys.which("python")

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
