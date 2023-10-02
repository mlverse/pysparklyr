test_that("build_user_agent() outputs work", {
  x <- build_user_agent()
  expect_equal(substr(x, 1,8), "sparklyr")

  Sys.setenv("RSTUDIO_PRODUCT" = "CONNECT")
  expect_equal(
    build_user_agent(),
    paste0("sparklyr/", packageVersion("sparklyr"), " posit-connect")
    )

  Sys.setenv("SPARK_CONNECT_USER_AGENT" = "testagent")
  expect_equal(build_user_agent(), "testagent")

})

test_that("DBR error code returns as expected", {
  error <- paste0(
    "SparkConnectGrpcException('<_InactiveRpcError of RPC that terminated with:",
    "\n\tstatus = StatusCode.UNAVAILABLE\n\tdetails = 'RESOURCE_DOES_NOT_EXIST: No",
    " cluster found matching: asdfasdf'\n\tdebug_error_string = 'UNKNOWN:Error",
    " received from peer  {grpc_message:'RESOURCE_DOES_NOT_EXIST: No cluster",
    " found matching: asdfasdf', grpc_status:5,",
    " created_time:'2023-10-02T12:14:52.379226-05:00'}'\n>')"
  )

  expect_error(cluster_dbr_error(error))
})


test_that("Cluster info runs as expected", {
  expect_equal(cluster_dbr_version(""), "")
})
