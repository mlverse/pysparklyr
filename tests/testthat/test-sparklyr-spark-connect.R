test_that("User agent builder basic", {
  withr::with_envvar(
    new = c("RSTUDIO_PRODUCT" = NA),
    {
      x <- build_user_agent()
      expect_equal(substr(x, 1, 8), "sparklyr")
    }
  )
})

test_that("User agent builder acknowledges when product is Connectr", {
  withr::with_envvar(
    new = c("RSTUDIO_PRODUCT" = "CONNECT"),
    {
      expect_equal(
        build_user_agent(),
        glue("sparklyr/{packageVersion('sparklyr')} posit-connect")
      )
    }
  )
})

test_that("User agent builder works with Connect env var", {
  withr::with_envvar(
    new = c("SPARK_CONNECT_USER_AGENT" = "testagent"),
    {
      expect_equal(build_user_agent(), "testagent")
    }
  )
})

use_test_rs_version <- function() {
  x <- list()
  x$mode <- "server"
  x$edition <- "Professional"
  x$long_version <- "2023.12.0"
  x
}

test_that("User agent works on RStudio Workbench", {
  withr::with_envvar(
    new = c("RSTUDIO_PRODUCT" = NA),
    {
      local_mocked_bindings(
        check_rstudio = function(...) TRUE,
        int_rstudio_version = function(...) use_test_rs_version()
      )
      expect_equal(
        build_user_agent(),
        glue(
          "sparklyr/{packageVersion('sparklyr')} posit-workbench-rstudio/2023.12.0"
          )
        )
    }
  )
})

test_that("User agent works on RStudio Pro", {
  withr::with_envvar(
    new = c("RSTUDIO_PRODUCT" = NA),
    {
      local_mocked_bindings(
        check_rstudio = function(...) TRUE,
        int_rstudio_version = function(...) {
          x <- use_test_rs_version()
          x$mode <- "desktop"
          x
        }
      )
      expect_equal(
        build_user_agent(),
        glue(
          "sparklyr/{packageVersion('sparklyr')} posit-rstudio-pro/2023.12.0"
        )
      )
    }
  )
})


test_that("User agent builder works with Connect env var", {
  withr::with_envvar(
    new = c("R_CONFIG_ACTIVE" = "rstudio_cloud"),
    {
      local_mocked_bindings(
        check_rstudio = function(...) TRUE,
        int_rstudio_version = function(...) {
          x <- use_test_rs_version()
          x$mode <- "desktop"
          x
        }
      )
      expect_equal(
        build_user_agent(),
        glue(
          "sparklyr/{packageVersion('sparklyr')} posit-cloud-rstudio/2023.12.0"
        )
        )
    }
  )
})
