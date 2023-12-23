test_that("Schema outputs as expected", {
  tbl_mtcars <- use_test_table_mtcars()
  expect_snapshot(sdf_schema(tbl_mtcars))
})

