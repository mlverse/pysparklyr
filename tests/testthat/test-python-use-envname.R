env_path <- fs::path(tempdir(), random_table_name("env"))

test_that("Install environment", {
  withr::with_envvar(
    new = c("WORKON_HOME" = env_path),
    {
      expect_output(
        install_pyspark("3.4", as_job = FALSE, python = Sys.which("python")),
        as_job = FALSE,
        python = Sys.which("python")
      )
    }
  )
})

test_that("Use first one", {
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
    new = c("WORKON_HOME" = env_path),
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
    new = c("WORKON_HOME" = env_path),
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
    new = c("WORKON_HOME" = env_path),
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
    new = c("WORKON_HOME" = env_path),
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

test_that("Expect error when no 'version' is provided", {
  expect_error(use_envname(version = NULL))
})


test_that("Requirements work", {
  reqs <- python_requirements(
    backend = "pyspark",
    main_library = "pyspark",
    version = "3.4"
  )
  expect_equal(c("packages", "python_version"), names(reqs))
})
