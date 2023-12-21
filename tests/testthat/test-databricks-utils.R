skip_if_not_databricks()

test_that("DBR error code returns as expected", {
  error <- paste0(
    "SparkConnectGrpcException('<_InactiveRpcError of RPC that terminated with:",
    "\n\tstatus = StatusCode.UNAVAILABLE\n\tdetails = 'RESOURCE_DOES_NOT_EXIST: No",
    " cluster found matching: asdfasdf'\n\tdebug_error_string = 'UNKNOWN:Error",
    " received from peer  {grpc_message:'RESOURCE_DOES_NOT_EXIST: No cluster",
    " found matching: asdfasdf', grpc_status:5,",
    " created_time:'2023-10-02T12:14:52.379226-05:00'}'\n>')"
  )

  expect_error(databricks_dbr_error(error))
})

test_that("Databricks Host works", {
  expect_true(nchar(databricks_host()) > 5)
})

test_that("Databricks Token works", {
  expect_true(nchar(databricks_token()) > 5)
})

test_that("Get cluster version", {
  expect_message(
    x <- databricks_dbr_version(
      cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID", unset = NA),
      host = databricks_host(),
      token = databricks_token()
    )
  )
  expect_true(nchar(x) == 4)
})

test_that("Cluster info runs as expected", {
  expect_error(databricks_dbr_version(""))
})

test_that("Host sanitation works", {
  clean_url <- "https://cloud.databricks.com"
  expect_equal(sanitize_host("cloud.databricks.com"), clean_url)
  expect_equal(sanitize_host("https://cloud.databricks.com"), clean_url)
  expect_equal(sanitize_host("https://cloud.databricks.com/"), clean_url)
  expect_equal(sanitize_host("https://cloud.databricks.com/?o=123#"), clean_url)
})
