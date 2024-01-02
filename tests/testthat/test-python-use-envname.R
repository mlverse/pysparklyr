test_that("Message when RETICULATE_PYTHON is set", {
  py_to_use <- py_exe()
  withr::with_envvar(
    new = c("RETICULATE_PYTHON" = py_to_use),
    {
      Sys.setenv("RETICULATE_PYTHON" = py_to_use)
      expect_message(use_envname("newtest", messages = TRUE))
    }
  )
})

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
          version = "1.1",
          messages = TRUE,
          match_first = TRUE,
          ask_if_not_installed = FALSE
        ),
        "No exact Python Environment was found for"
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
        ),
        "No exact Python Environment was found for"
      )
    }
  )

})

test_that("'Ask to install', simulates menu selection", {
  withr::with_envvar(
    new = c("WORKON_HOME" = env_path),
    {
      local_mocked_bindings(
        check_interactive = function(...) TRUE,
        check_rstudio = function(...) TRUE,
        menu = function(...) return(1),
        exec = function(...) list(...)
        )
      expect_equal(
        use_envname(
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
