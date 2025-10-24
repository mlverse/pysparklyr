test_that("Databricks Connect", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    {
      local_mocked_bindings(
        initialize_connection = function(...) {
          return(list(...))
        },
        databricks_dbr_info = function(...) {
          return(list(cluster_name = "test_host"))
        }
      )
      py_require("databricks-connect")
      sc_out <- spark_connect_method.spark_method_databricks_connect(
        method = "databricks_connect",
        master = NULL,
        envname = py_exe(),
        version = "17.1",
        cluster_id = "test_cluster"
      )
      expect_equal(sc_out$master_label, "test_host (test_cluster)")
      expect_equal(sc_out$cluster_id, "test_cluster")
    }
  )
})

