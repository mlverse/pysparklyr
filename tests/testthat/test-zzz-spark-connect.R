test_that("build_user_agent() outputs work", {
  x <- build_user_agent()
  expect_equal(substr(x, 1, 8), "sparklyr")

  Sys.setenv("RSTUDIO_PRODUCT" = "CONNECT")
  expect_equal(
    build_user_agent(),
    paste0("sparklyr/", packageVersion("sparklyr"), " posit-connect")
  )

  Sys.setenv("SPARK_CONNECT_USER_AGENT" = "testagent")
  expect_equal(build_user_agent(), "testagent")
  Sys.unsetenv("SPARK_CONNECT_USER_AGENT")
})

skip_if_not_databricks()

test_that("Test Databricks connection", {
  local_mocked_bindings(
    initialize_connection = function(...) list(...)
    )
  py_install("databricks.connect")
  sc <- spark_connect_method.spark_method_databricks_connect(
    master = NULL,
    method = "databricks_connect",
    config = NULL
    )
  expect_s3_class(sc$conn, "databricks.connect.session.Builder")
  expect_equal(sc$con_class, "connect_databricks")
  expect_equal(sc$cluster_id, Sys.getenv("DATABRICKS_CLUSTER_ID"))
  expect_equal(sc$method, "databricks_connect")
  expect_null(sc$config)
})


