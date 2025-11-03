skip_spark_min_version("4")
test_that("Databricks Connect", {
  withr::with_envvar(
    new = c(
      "WORKON_HOME" = use_test_env(),
      "DATABRICKS_HOST" = "testhost",
      "DATABRICKS_TOKEN" = "testtoken"
    ),
    {
      local_mocked_bindings(
        initialize_connection = function(...) {
          return(list(...))
        },
        databricks_dbr_info = function(...) {
          return(list(cluster_name = "test_host"))
        },
        import_check = function(...) {
          out <- list()
          out$DatabricksSession$builder$sdkConfig <- function(...) {
            x <- list()
            x$userAgent <- function(...) {
              return(list())
            }
            x
          }
          out$core$Config <- function(...) {
            x <- list()
            x$token <- "testtoken"
          }
          out
        },
        databricks_sdk_client = function(...) {
          return(NULL)
        }
      )

      sc_out <- spark_connect_method.spark_method_databricks_connect(
        method = "databricks_connect",
        master = NULL,
        envname = use_test_python_environment(),
        version = "17.1",
        cluster_id = "test_cluster"
      )
      expect_equal(sc_out$master_label, "test_host (test_cluster)")
      expect_equal(sc_out$cluster_id, "test_cluster")
    }
  )
})

test_that("Snowpark Connect (Snowflake)", {
  withr::with_envvar(
    new = c(
      "WORKON_HOME" = use_test_env()
    ),
    {
      local_mocked_bindings(
        initialize_connection = function(...) {
          return(list(...))
        },
        import_check = function(...) {
          out <- list()
          out$Session$builder$configs <- function(...) {
            list(...)
          }
          out
        },
        databricks_sdk_client = function(...) {
          return(NULL)
        }
      )
      sc_out <- spark_connect_method.spark_method_snowpark_connect(
        method = "snowpark_connect",
        master = NULL,
        connection_parameters = list(
          user = "test@user.com",
          password = "testtoken",
          warehouse = "testwh",
          database = "testdb",
          schema = "testschema"
        )
      )
      expect_snapshot(sc_out)
    }
  )
})

