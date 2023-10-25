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

test_that("version_prep() outputs what's expected", {
  expect_error(version_prep(""))
  expect_error(version_prep("1"))
  expect_equal(version_prep("1.1"), "1.1")
  expect_equal(version_prep("1.1.1"), "1.1")
  expect_error(version_prep("1.1.1.1"))
})

skip_if(
  !identical(Sys.getenv("CODE_COVERAGE"), "true"),
  message = "Reserved for coverage only"
  )

test_that("PySpark installation works", {
  expect_output(install_pyspark("3.3", as_job = FALSE, python = Sys.which("python")))
  reticulate::virtualenv_remove("r-sparklyr-pyspark-3.3", confirm = FALSE)
})

test_that("DB Connect installation works", {
  expect_output(install_databricks("13.0", as_job = FALSE, python = Sys.which("python")))
  reticulate::virtualenv_remove("r-sparklyr-databricks-13.0", confirm = FALSE)
})
