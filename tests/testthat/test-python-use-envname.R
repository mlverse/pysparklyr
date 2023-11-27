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
        install_pyspark("3.4", as_job = FALSE)
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

  fs::dir_delete(env_path)
})
