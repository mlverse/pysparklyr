test_that("installed_components() output properly", {
  sc <- test_spark_connect()
  expect_message(installed_components())
})

test_that("Can get pypy.org info", {

  info <- py_library_info("databricks.connect", "13.0")
  expect_type(info, "list")
  expect_equal(info$summary, "Databricks Connect Client")

  expect_null(py_library_info("doesnt.exist", ""))
})
