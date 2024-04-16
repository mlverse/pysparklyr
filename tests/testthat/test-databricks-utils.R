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
