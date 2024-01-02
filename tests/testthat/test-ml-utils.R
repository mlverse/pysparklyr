test_that("ml_formula() works", {
  expect_snapshot(ml_formula(am ~ mpg, mtcars))
  expect_error(
    ml_formula(am ~ mpg * cyl, mtcars),
    "Formula resulted in an invalid parameter set"
  )
})

test_that("snake_to_camel() works", {
  expect_equal(
    snake_to_camel("var_one"),
    "varOne"
  )
})

test_that("ml_connect_not_supported() works", {
  expect_silent(
    ml_connect_not_supported(
      args = list(),
      not_supported = c(
        "elastic_net_param", "reg_param", "threshold",
        "aggregation_depth", "fit_intercept",
        "raw_prediction_col", "uid", "weight_col"
      )
    )
  )

  expect_error(
    ml_connect_not_supported(
      args = list(reg_param = 1),
      not_supported = c(
        "elastic_net_param", "reg_param", "threshold",
        "aggregation_depth", "fit_intercept",
        "raw_prediction_col", "uid", "weight_col"
      ),
      "The following argument(s) are not supported by Spark Connect:"
    )
  )
})

test_that("ml_installed() works on simulated interactive session", {
  skip_if_not_databricks()

  test_env <- test_databricks_stump_env() %>%
    path_dir() %>%
    path_dir()

  withr::with_envvar(
    new = c("WORKON_HOME" = test_env),
    {
      local_mocked_bindings(
        check_interactive = function(...) TRUE,
        check_rstudio = function(...) TRUE,
        menu = function(...) {
          return(1)
        },
        py_install = function(...) invisible()
      )
      expect_snapshot(
        ml_installed()
      )
    }
  )
})
