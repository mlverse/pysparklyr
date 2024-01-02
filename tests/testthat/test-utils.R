test_that("Reticulate Python check works", {
  withr::with_envvar(
    new = c("RETICULATE_PYTHON" = "path/for/python"),
    {
      expect_equal(
        reticulate_python_check(ignore = TRUE),
        ""
      )
      expect_message(
        reticulate_python_check(unset = FALSE, message = TRUE),
        "Your 'RETICULATE_PYTHON' environment is set, which may cause"
        )
    })

})

test_that("When in Posit Connect no unset happens", {
  local_mocked_bindings(current_product_connect = function(...) TRUE)
  withr::with_envvar(
    new = c("RETICULATE_PYTHON" = "path/for/python"),
    {
      expect_equal(
        reticulate_python_check(),
        "path/for/python"
      )
    })
})

test_that("Check arguments works", {
  x <- ""
  expect_error(
    check_arg_supported(x),
    "The 'x' argument is not currently supported for this back-end"
  )

})
