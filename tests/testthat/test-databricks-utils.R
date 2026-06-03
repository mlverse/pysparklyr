test_that("DBR error code returns as expected", {
  error <- paste0(
    "SparkConnectGrpcException('<_InactiveRpcError of RPC that terminated with:",
    "\n\tstatus = StatusCode.UNAVAILABLE\n\tdetails = 'RESOURCE_DOES_NOT_EXIST: No",
    " cluster found matching: asdfasdf'\n\tdebug_error_string = 'UNKNOWN:Error",
    " received from peer  {grpc_message:'RESOURCE_DOES_NOT_EXIST: No cluster",
    " found matching: asdfasdf', grpc_status:5,",
    " created_time:'2023-10-02T12:14:52.379226-05:00'}'\n>')"
  )

  expect_snapshot(databricks_dbr_error(error), error = TRUE)

  expect_snapshot(databricks_dbr_error(""), error = TRUE)
})

test_that("Get cluster version", {
  vcr::local_cassette("databricks-cluster-version")
  expect_equal(
    databricks_dbr_version(
      host = use_test_db_host(),
      token = "",
      cluster_id = use_test_db_cluster()
    ),
    "17.3"
  )
})

test_that("Cluster info runs as expected", {
  expect_error(databricks_dbr_version(""))
})

test_that("Misc tests", {
  expect_snapshot(allowed_serverless_configs())
})

test_that("DBR Python comes back as expected", {
  expect_equal(databricks_dbr_python("17.0"), "3.12")
  expect_equal(databricks_dbr_python("15.0"), "3.11")
  expect_equal(databricks_dbr_python("14.0"), "3.10")
})

test_that("connectcreds_databricks_token returns viewer token", {
  local_mocked_connect_responses(token = "my-viewer-token")
  result <- connectcreds_databricks_token("https://my.cloud.databricks.com")
  expect_equal(result, "my-viewer-token")
})

test_that("connectcreds_databricks_token returns service account token", {
  local_mocked_connect_responses(
    token = "my-sa-token",
    type = "service_account"
  )
  result <- connectcreds_databricks_token("https://my.cloud.databricks.com")
  expect_equal(result, "my-sa-token")
})

test_that("connectcreds_databricks_token returns NULL when no token", {
  local_mocked_bindings(
    has_viewer_token = function(...) FALSE,
    has_service_account_token = function(...) FALSE
  )
  result <- connectcreds_databricks_token("https://my.cloud.databricks.com")
  expect_null(result)
})

test_that("connectcreds_databricks_token adds https:// prefix", {
  local_mocked_connect_responses(token = "my-viewer-token")
  result <- connectcreds_databricks_token("my.cloud.databricks.com")
  expect_equal(result, "my-viewer-token")
})
