test_that("import_check() exception tests", {
  sc <- use_test_spark_connect()

  exe_location <- reticulate::py_exe()
  exe_folders <- unlist(strsplit(exe_location, "/"))
  env_name <- exe_folders[length(exe_folders) - 2]

  expect_error(import_check("not.real", env_name))
})
