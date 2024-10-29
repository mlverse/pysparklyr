test_that("Writing requirements works", {
  req_folder <- path(tempdir(), random_table_name("req"))
  req_file <- path(req_folder, "requirements.txt")
  dir_create(req_folder)
  sc <- use_test_spark_connect()

  expect_message(
    requirements_write(destfile = req_file),
    "Python library requirements"
  )

  expect_error(
    requirements_write(destfile = req_file),
    "File 'requirements.txt' already exists"
  )

  expect_message(
    requirements_write(destfile = req_file, overwrite = TRUE),
    "Python library requirements"
  )
})
