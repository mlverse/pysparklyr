test_that("Install environment", {
  withr::with_envvar(
    new = c(
      "WORKON_HOME" = use_new_temp_env()
    ),
    {
      expect_output(
        install_pyspark("3.4", as_job = FALSE)
      )
    }
  )
})

test_that("Use first one", {
  env_path <- use_new_temp_env()
  dir_create(path(env_path, "r-sparklyr-pyspark-3.4"))
  withr::with_envvar(
    new = c("WORKON_HOME" = env_path),
    {
      expect_message(
        x <- use_envname(
          main_library = "pyspark",
          version = "1.1",
          messages = TRUE,
          match_first = TRUE,
          ask_if_not_installed = FALSE
        ),
        "You do not have a Python environment that matches"
      )
      expect_named(x, "first")
    }
  )
})

test_that("Error if 'use_first' is not TRUE", {
  env_path <- use_new_temp_env()
  dir_create(path(env_path, "r-sparklyr-pyspark-3.4"))
  withr::with_envvar(
    new = c("WORKON_HOME" = env_path),
    {
      expect_message(
        x <- use_envname(
          version = "100.0",
          messages = TRUE,
          match_first = TRUE,
          main_library = "pyspark",
          ask_if_not_installed = FALSE
        ),
        "Library Spark Connect version 100.0 is not yet available"
      )
    }
  )
})

test_that("Error if 'use_first' is not TRUE", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_new_temp_env()),
    {
      expect_error(
        x <- use_envname(
          version = "1.1",
          messages = TRUE,
          match_first = FALSE,
          ask_if_not_installed = FALSE
        )
      )
    }
  )
})

test_that("'Ask to install', simulates menu selection 'Yes'", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_new_temp_env()),
    {
      local_mocked_bindings(
        check_interactive = function(...) TRUE,
        check_rstudio = function(...) TRUE,
        menu = function(...) {
          return(1)
        },
        exec = function(...) list(...)
      )
      expect_equal(
        use_envname(
          main_library = "pyspark",
          version = "1.1",
          messages = TRUE,
          match_first = FALSE,
          ask_if_not_installed = TRUE
        ),
        rlang::set_names("r-sparklyr-pyspark-1.1", "prompt")
      )
    }
  )
})

test_that("'Ask to install', simulates menu selection 'No'", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_new_temp_env()),
    {
      local_mocked_bindings(
        check_interactive = function(...) TRUE,
        check_rstudio = function(...) TRUE,
        menu = function(...) {
          return(2)
        },
        exec = function(...) list(...)
      )
      expect_equal(
        use_envname(
          main_library = "pyspark",
          version = "1.1",
          messages = TRUE,
          match_first = FALSE,
          ask_if_not_installed = TRUE
        ),
        rlang::set_names("r-sparklyr-pyspark-1.1", "prompt")
      )
    }
  )
})

test_that("'Ask to install', simulates menu selection 'Cancel'", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_new_temp_env()),
    {
      local_mocked_bindings(
        check_interactive = function(...) TRUE,
        check_rstudio = function(...) TRUE,
        menu = function(...) {
          return(3)
        },
        exec = function(...) list(...)
      )
      expect_error(
        use_envname(
          version = "1.1",
          messages = TRUE,
          match_first = FALSE,
          ask_if_not_installed = TRUE
        )
      )
    }
  )
})

test_that("Expect error when no 'version' is provided and no 'main_library'", {
  expect_error(use_envname(version = NULL, main_library = NULL))
})

test_that("Auto-detect version from PyPI when version is NULL", {
  env_path <- use_new_temp_env()
  withr::with_envvar(
    new = c("WORKON_HOME" = env_path),
    {
      local_mocked_bindings(
        python_library_info = function(
          library_name,
          library_version = NULL,
          verbose = TRUE,
          fail = TRUE,
          timeout = 2
        ) {
          list(
            version = "3.5.0",
            requires_python = ">=3.8",
            name = library_name
          )
        }
      )
      x <- use_envname(
        main_library = "pyspark",
        version = NULL,
        messages = FALSE,
        match_first = FALSE,
        ask_if_not_installed = FALSE
      )
      expect_named(x, "latest")
      expect_equal(as.character(x), "r-sparklyr-pyspark-3.5")
    }
  )
})

test_that("Auto-detect uses latest version for databricks.connect", {
  env_path <- use_new_temp_env()
  withr::with_envvar(
    new = c("WORKON_HOME" = env_path),
    {
      local_mocked_bindings(
        python_library_info = function(
          library_name,
          library_version = NULL,
          verbose = TRUE,
          fail = TRUE,
          timeout = 2
        ) {
          list(
            version = "14.2.0",
            requires_python = ">=3.8",
            name = library_name
          )
        }
      )
      x <- use_envname(
        main_library = "databricks.connect",
        version = NULL,
        backend = "databricks",
        messages = FALSE,
        match_first = FALSE,
        ask_if_not_installed = FALSE
      )
      expect_named(x, "latest")
      expect_equal(as.character(x), "r-sparklyr-databricks-14.2")
    }
  )
})

test_that("Falls back to error when PyPI query fails and no version provided", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_new_temp_env()),
    {
      local_mocked_bindings(
        python_library_info = function(
          library_name,
          library_version = NULL,
          verbose = TRUE,
          fail = TRUE,
          timeout = 2
        ) {
          return(NULL)
        }
      )
      expect_error(
        use_envname(
          main_library = "pyspark",
          version = NULL,
          messages = FALSE
        ),
        "A cluster.*version.*is required"
      )
    }
  )
})

test_that("Explicit version returns 'unavailable' not 'latest'", {
  env_path <- use_new_temp_env()
  withr::with_envvar(
    new = c("WORKON_HOME" = env_path),
    {
      x <- use_envname(
        main_library = "pyspark",
        version = "3.5.0",
        messages = FALSE,
        match_first = FALSE,
        ask_if_not_installed = FALSE
      )
      expect_named(x, "unavailable")
      expect_equal(as.character(x), "r-sparklyr-pyspark-3.5")
    }
  )
})

test_that("Auto-detect finds exact match when environment exists", {
  env_path <- use_new_temp_env()
  dir_create(path(env_path, "r-sparklyr-pyspark-3.5"))
  withr::with_envvar(
    new = c("WORKON_HOME" = env_path),
    {
      local_mocked_bindings(
        python_library_info = function(
          library_name,
          library_version = NULL,
          verbose = TRUE,
          fail = TRUE,
          timeout = 2
        ) {
          list(
            version = "3.5.0",
            requires_python = ">=3.8",
            name = library_name
          )
        }
      )
      x <- use_envname(
        main_library = "pyspark",
        version = NULL,
        messages = FALSE,
        match_first = FALSE,
        ask_if_not_installed = FALSE
      )
      expect_named(x, "exact")
      expect_equal(as.character(x), "r-sparklyr-pyspark-3.5")
    }
  )
})


test_that("Requirements work", {
  reqs <- python_requirements(
    backend = "pyspark",
    main_library = "pyspark",
    version = "3.4"
  )
  expect_equal(c("packages", "python_version"), names(reqs))
})
