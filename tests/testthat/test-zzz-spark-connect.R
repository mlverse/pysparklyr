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
      "WORKON_HOME" = use_test_env(),
      "SNOWFLAKE_DEFAULT_CONNECTION_NAME" = NA,
      "SNOWFLAKE_ACCOUNT" = NA,
      "RSTUDIO_PRODUCT" = NA
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
        master = "testaccount",
        connection_parameters = list(
          user = "test@user.com",
          password = "testtoken",
          warehouse = "testwh",
          database = "testdb",
          schema = "testschema"
        )
      )
      expect_snapshot(sc_out)
      sc_no_master <- spark_connect_method.spark_method_snowpark_connect(
        method = "snowpark_connect",
        connection_parameters = list(
          user = "test@user.com",
          password = "testtoken",
          warehouse = "testwh",
          database = "testdb",
          schema = "testschema"
        )
      )
      expect_equal(sc_no_master$master_label, "Snowpark Connect")
      expect_null(sc_no_master$conn[[1]]$account)
    }
  )
})

test_that("Snowpark Connect works with connection_name, no master", {
  withr::local_envvar(c(
    "WORKON_HOME" = use_test_env(),
    "SNOWFLAKE_DEFAULT_CONNECTION_NAME" = NA,
    "SNOWFLAKE_ACCOUNT" = NA,
    "RSTUDIO_PRODUCT" = NA
  ))
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
    }
  )
  sc_out <- spark_connect_method.spark_method_snowpark_connect(
    method = "snowpark_connect",
    connection_parameters = list(
      connection_name = "myconn"
    )
  )
  expect_equal(sc_out$master_label, "Snowpark Connect")
  expect_null(sc_out$conn[[1]]$account)
})

test_that("Snowpark Connect works with SNOWFLAKE_DEFAULT_CONNECTION_NAME", {
  withr::local_envvar(c(
    "WORKON_HOME" = use_test_env(),
    "SNOWFLAKE_DEFAULT_CONNECTION_NAME" = "default",
    "SNOWFLAKE_ACCOUNT" = NA,
    "RSTUDIO_PRODUCT" = NA
  ))
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
    }
  )
  sc_out <- spark_connect_method.spark_method_snowpark_connect(
    method = "snowpark_connect"
  )
  expect_equal(sc_out$master_label, "Snowpark Connect")
})

test_that("Snowpark Connect named connection ignores SNOWFLAKE_ACCOUNT env var", {
  withr::local_envvar(c(
    "WORKON_HOME" = use_test_env(),
    "SNOWFLAKE_DEFAULT_CONNECTION_NAME" = NA,
    "SNOWFLAKE_ACCOUNT" = "env-account",
    "RSTUDIO_PRODUCT" = NA
  ))
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
    }
  )
  sc_out <- spark_connect_method.spark_method_snowpark_connect(
    method = "snowpark_connect",
    connection_parameters = list(
      connection_name = "myconn"
    )
  )
  expect_null(sc_out$conn[[1]]$account)
})

test_that("Snowpark Connect named connection ignores env account with viewer token", {
  withr::local_envvar(c(
    "WORKON_HOME" = use_test_env(),
    "SNOWFLAKE_DEFAULT_CONNECTION_NAME" = NA,
    "SNOWFLAKE_ACCOUNT" = "env-account"
  ))
  connectcreds::local_mocked_connect_responses(token = "viewer-token-value")
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
    }
  )
  sc_out <- spark_connect_method.spark_method_snowpark_connect(
    method = "snowpark_connect",
    connection_parameters = list(
      connection_name = "myconn"
    )
  )
  expect_null(sc_out$conn[[1]]$account)
  expect_null(sc_out$conn[[1]]$authenticator)
  expect_equal(sc_out$master_label, "Snowpark Connect")
})

test_that("Snowpark Connect uses connectcreds viewer token", {
  withr::local_envvar(c(
    "WORKON_HOME" = use_test_env(),
    "SNOWFLAKE_DEFAULT_CONNECTION_NAME" = NA,
    "SNOWFLAKE_ACCOUNT" = NA
  ))
  connectcreds::local_mocked_connect_responses(token = "viewer-token-value")
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
    }
  )
  sc_out <- spark_connect_method.spark_method_snowpark_connect(
    method = "snowpark_connect",
    master = "testaccount"
  )
  expect_equal(sc_out$conn[[1]]$authenticator, "oauth")
  expect_equal(sc_out$conn[[1]]$token, "viewer-token-value")
  expect_equal(sc_out$conn[[1]]$account, "testaccount")
  expect_equal(sc_out$master_label, "Snowpark Connect - testaccount")
})

test_that("Snowpark Connect uses connectcreds with account in connection_parameters", {
  withr::local_envvar(c(
    "WORKON_HOME" = use_test_env(),
    "SNOWFLAKE_DEFAULT_CONNECTION_NAME" = NA,
    "SNOWFLAKE_ACCOUNT" = NA
  ))
  connectcreds::local_mocked_connect_responses(token = "viewer-token-value")
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
    }
  )
  sc_out <- spark_connect_method.spark_method_snowpark_connect(
    method = "snowpark_connect",
    connection_parameters = list(
      account = "testaccount"
    )
  )
  expect_equal(sc_out$conn[[1]]$authenticator, "oauth")
  expect_equal(sc_out$conn[[1]]$token, "viewer-token-value")
  expect_equal(sc_out$conn[[1]]$account, "testaccount")
  expect_equal(sc_out$master_label, "Snowpark Connect - testaccount")
})

test_that("Snowpark Connect viewer token overrides explicit credentials", {
  withr::local_envvar(c(
    "WORKON_HOME" = use_test_env(),
    "SNOWFLAKE_DEFAULT_CONNECTION_NAME" = NA,
    "SNOWFLAKE_ACCOUNT" = NA
  ))
  connectcreds::local_mocked_connect_responses(token = "viewer-token-value")
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
    }
  )
  sc_out <- spark_connect_method.spark_method_snowpark_connect(
    method = "snowpark_connect",
    master = "testaccount",
    connection_parameters = list(
      password = "explicit-password",
      authenticator = "snowflake"
    )
  )
  expect_equal(sc_out$conn[[1]]$authenticator, "oauth")
  expect_equal(sc_out$conn[[1]]$token, "viewer-token-value")
})

test_that("installed_components() output properly", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_new_test_env()),
    {
      expect_message(installed_components())
    }
  )
})
