skip_on_ci()
skip_spark_min_version(4.0)

test_that("R Formula works with Spark Connection", {
  use_test_install_ml()
  sc <- use_test_spark_connect()
  expect_snapshot(
    class(ft_r_formula(sc))
  )
})
test_that("R Formula works with `tbl_spark`", {
  tbl_mtcars <- use_test_table_mtcars()
  expect_s3_class(
    ft_r_formula(
      tbl_mtcars,
      mpg ~ .,
      features_col = "test"
    ),
    "tbl_pyspark"
  )
})

test_that("R Formula works with Pipeline", {
  sc <- use_test_spark_connect()

  expect_silent(
    out <- sc %>%
      ml_pipeline() %>%
      ft_r_formula()
  )

  cap_out <- capture.output(out)
  expect_snapshot(cap_out[c(1, 3:4)])
})
