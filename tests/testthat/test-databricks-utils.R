test_that("DBR error code returns as expected", {
  error <- paste0(
    "SparkConnectGrpcException('<_InactiveRpcError of RPC that terminated with:",
    "\n\tstatus = StatusCode.UNAVAILABLE\n\tdetails = 'RESOURCE_DOES_NOT_EXIST: No",
    " cluster found matching: asdfasdf'\n\tdebug_error_string = 'UNKNOWN:Error",
    " received from peer  {grpc_message:'RESOURCE_DOES_NOT_EXIST: No cluster",
    " found matching: asdfasdf', grpc_status:5,",
    " created_time:'2023-10-02T12:14:52.379226-05:00'}'\n>')"
  )

  expect_snapshot_error(databricks_dbr_error(error))

  expect_snapshot_error(databricks_dbr_error(""))
})

test_that("Databricks Host works", {
  skip_if_no_db_host()
  expect_true(nchar(databricks_host()) > 5)

  expect_named(databricks_host("thisisatest"), "argument")

  expect_error(
    withr::with_envvar(
      new = c("DATABRICKS_HOST" = NA, "DATABRICKS_TOKEN" = NA),
      {
        databricks_host()
      }
    ),
    "No Host URL was provided"
  )

  expect_named(
    withr::with_envvar(
      new = c("DATABRICKS_HOST" = NA, "CONNECT_DATABRICKS_HOST" = "testing"),
      {
        databricks_host()
      }
    ),
    "environment_connect"
  )
})

test_that("Databricks Token works", {
  skip_if(
    inherits(try(databricks_token(), silent = TRUE), "try-error"),
    "No Databricks Token available"
  )
  expect_true(nchar(databricks_token()) > 5)

  expect_named(databricks_token("thisisatest"), "argument")

  expect_error(
    withr::with_envvar(
      new = c("DATABRICKS_HOST" = NA, "DATABRICKS_TOKEN" = NA),
      {
        databricks_token(fail = TRUE)
      }
    ),
    "No authentication token was identified"
  )

  expect_named(
    withr::with_envvar(
      new = c("DATABRICKS_TOKEN" = NA, "CONNECT_DATABRICKS_TOKEN" = "testing"),
      {
        databricks_token()
      }
    ),
    "environment_connect"
  )
})

test_that("Get cluster version", {
  withr::with_envvar(
    new = c("DATABRICKS_HOST" = "xxxxx", "DATABRICKS_TOKEN" = "xxxxx"),
    {
      local_mocked_bindings(
        databricks_cluster_get = function(...) {
          readRDS(test_path("_mock/cluster_get.rds"))
        }
      )
      expect_message(
        x <- databricks_dbr_version(
          cluster_id = "xxxxx",
          host = databricks_host(),
          token = databricks_token()
        )
      )
      expect_true(nchar(x) == 4)
    }
  )

})

test_that("Get cluster version", {
  withr::with_envvar(
    new = c("DATABRICKS_HOST" = "xxxxx", "DATABRICKS_TOKEN" = "xxxxx"),
    {
      local_mocked_bindings(
        databricks_cluster_get = function(...) {
          readRDS(test_path("_mock/cluster_get.rds"))
        }
      )
      expect_message(
        x <- databricks_dbr_version_name(
          cluster_id = "xxxxx",
          host = databricks_host(),
          token = databricks_token()
        )
      )
      expect_equal(
        databricks_extract_version(databricks_cluster_get()), "17.1"
      )
    }
  )

})

test_that("Cluster info runs as expected", {
  expect_error(databricks_dbr_version(""))
})

test_that("Misc tests", {
  expect_silent(databricks_desktop_login("xxxx", "xxxxx"))
  expect_snapshot(allowed_serverless_configs())
})

test_that("DBR Python comes back as expected", {
  expect_equal(databricks_dbr_python("17.0"), "3.12")
  expect_equal(databricks_dbr_python("15.0"), "3.11")
  expect_equal(databricks_dbr_python("14.0"), "3.10")
})

test_that("Host sanitation works", {
  clean_url <- "https://cloud.databricks.com"
  expect_equal(sanitize_host("cloud.databricks.com"), clean_url)
  expect_equal(sanitize_host("https://cloud.databricks.com"), clean_url)
  expect_equal(sanitize_host("https://cloud.databricks.com/"), clean_url)
  expect_equal(sanitize_host("https://cloud.databricks.com/?o=123#"), clean_url)
})
