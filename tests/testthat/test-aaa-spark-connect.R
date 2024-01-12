test_that("Version mismatch works", {
  alternate_version <- "3.4"
  version <- use_test_version_spark()
  if (alternate_version != version) {
    withr::with_envvar(
      new = c("WORKON_HOME" = use_test_env()),
      {
        use_test_connect_start()
        expect_message(
          spark_connect(
            master = "sc://localhost",
            method = "spark_connect",
            version = alternate_version
          ),
          "You do not have a Python environment"
        )
      }
    )
  } else {
    skip("Alternate version matches")
  }
})
