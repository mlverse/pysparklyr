skip_spark_min_version(3.5)

test_that("Standard Scaler works with Spark Connection", {
  sc <- use_test_spark_connect()
  expect_snapshot(
    class(ft_standard_scaler(sc))
  )
})
test_that("Standard Scaler works with `tbl_spark`", {
  tbl_mtcars <- use_test_table_mtcars()
  expect_s3_class(
    ft_standard_scaler(
      tbl_mtcars,
      input_col = c("wt", "mpg", "qsec"),
      output_col = "scaled_features"
    ),
    "tbl_pyspark"
  )
})

test_that("Standard Scaler works with Pipeline", {
  sc <- use_test_spark_connect()

  expect_silent(
    out <- sc %>%
      ml_pipeline() %>%
      ft_standard_scaler()
  )

  cap_out <- capture.output(out)
  expect_snapshot(cap_out[c(1, 3:4)])
})

test_that("Max Abs Scaler works with Spark Connection", {
  sc <- use_test_spark_connect()
  expect_snapshot(
    class(ft_max_abs_scaler(sc))
  )
})

test_that("Max Abs Scaler works with `tbl_spark`", {
  tbl_mtcars <- use_test_table_mtcars()
  expect_silent(
    scale <- ft_max_abs_scaler(
      tbl_mtcars,
      input_col = c("wt", "mpg", "qsec"),
      output_col = "scaled_features"
    )
  )
  expect_snapshot(colnames(scale))
})

test_that("Max Abs Scaler works with Pipeline", {
  sc <- use_test_spark_connect()

  expect_silent(
    out <- sc %>%
      ml_pipeline() %>%
      ft_max_abs_scaler()
  )

  cap_out <- capture.output(out)
  expect_snapshot(cap_out[c(1, 3:4)])
})


test_that("Print method works", {
  sc <- use_test_spark_connect()
  expect_equal(
    print(ft_standard_scaler(sc)),
    as.character(NA)
  )
})
