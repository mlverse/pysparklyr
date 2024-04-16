test_that("Snippet caller works", {
  local_mocked_bindings(
    showQuestion = function(...) FALSE,
    get_wrapper = function(...) {
      ret <- function(x) x
      return(ret)
    }
  )
  x <- connection_databricks_shinyapp()
  expect_equal(path_file(x), "shinycon")
})

test_that("Snippet caller works", {
  local_mocked_bindings(
    showQuestion = function(...) TRUE,
    get_wrapper = function(...) {
      ret <- function(x) x
      return(ret)
    },
    installed.packages = function(...) c()
  )
  expect_error(
    connection_databricks_shinyapp(),
    "The `shiny` package is not installed, please install and retry"
  )
})

test_that("Get wrapper works", {
  expect_true(inherits(get_wrapper("mean"), "function"))
})
