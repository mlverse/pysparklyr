test_that("Message when RETICULATE_PYTHON is set", {
  py_to_use <- py_exe()
  Sys.setenv("RETICULATE_PYTHON" = py_to_use)
  expect_message(use_envname("newtest", messages = TRUE))
  Sys.unsetenv("RETICULATE_PYTHON")
})

test_that("Use first one", {
  expect_message(
    x <- use_envname(version = "1.1", messages = TRUE, match_first = TRUE),
    "No exact Python Environment was found for"
  )
  expect_named(x, "first")
})

test_that("Error if 'use_first' is not TRUE", {
  expect_error(
    x <- use_envname(
      version = "1.1",
      messages = TRUE,
      match_first = FALSE,
      ask_if_not_installed = FALSE
      ),
    "No exact Python Environment was found for"
  )
})
