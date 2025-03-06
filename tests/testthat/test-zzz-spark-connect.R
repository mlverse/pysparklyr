skip_if_not_databricks()

test_that("Test Databricks connection", {
  py_install("databricks.connect")
  sc <- spark_connect_method.spark_method_databricks_connect(
    master = NULL,
    method = "databricks_connect",
    envname = py_exe(),
    config = NULL
  )
  expect_s3_class(sc$conn, "databricks.connect.session.Builder")
  expect_equal(sc$con_class, "connect_databricks")
  expect_equal(sc$cluster_id, Sys.getenv("DATABRICKS_CLUSTER_ID"))
  expect_equal(sc$method, "databricks_connect")
  expect_null(sc$config)
})
