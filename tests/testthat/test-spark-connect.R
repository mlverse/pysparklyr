test_that("build_user_agent() outputs work", {
  x <- build_user_agent()
  expect_equal(substr(x, 1,8), "sparklyr")

  Sys.setenv("RSTUDIO_PRODUCT" = "CONNECT")
  expect_equal(
    build_user_agent(),
    paste0("sparklyr/", packageVersion("sparklyr"), " posit-connect")
    )

  Sys.setenv("SPARK_CONNECT_USER_AGENT" = "testagent")
  expect_equal(build_user_agent(), "testagent")

})

