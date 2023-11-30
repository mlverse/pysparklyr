test_that("Empty environment folder fails connection", {
  version <- use_test_version_spark()
  use_test_connect_start()
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    {
      expect_error(
        spark_connect(
          master = "sc://localhost",
          method = "spark_connect",
          version = version
        ),
        "No viable Python Environment was identified for Spark Connect"
      )
    })
})

test_that("Version mismatch works", {
  alternate_version <- "3.4"
  version <- use_test_version_spark()
  if (alternate_version != version) {
    use_test_python_environment()
    use_test_connect_start()
    expect_message(
      spark_connect(
        master = "sc://localhost",
        method = "spark_connect",
        version = alternate_version
      ),
      "No exact Python Environment was found for Spark Connect version 3.4"
    )
  } else {
    skip("Alternate version matches")
  }
})




