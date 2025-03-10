skip("Investicate 'PythonUDFEnvironment' issue")
skip_if_not_databricks()

test_that("Test Databricks connection", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    {
      sc <- use_test_spark_connect()
      pyspark_version <- python_library_info("pyspark")
      comp <- compareVersion(pyspark_version$version, spark_version(sc))
      if (comp != 0) {
        skip("Not latest version of Spark")
      }
      local_mocked_bindings(
        initialize_connection = function(...) list(...)
      )
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
    }
  )
})
