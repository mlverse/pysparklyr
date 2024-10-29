test_that("head() works", {
  tbl_mtcars <- use_test_table_mtcars()

  expect_equal(
    tbl_mtcars %>%
      head(5) %>%
      collect() %>%
      nrow(),
    5
  )
})

test_that("copy_to() works", {
  tbl_ordered <- use_test_table_mtcars() %>%
    arrange(mpg, qsec, hp)

  expect_snapshot(tbl_ordered)

  expect_snapshot(print(head(tbl_ordered)))
})

test_that("Sampling functions works", {
  tbl_mtcars <- use_test_table_mtcars()
  tbl_n <- tbl_mtcars %>%
    sample_n(5) %>%
    collect() %>%
    count() %>%
    pull()

  expect_equal(tbl_n, 5)

  tbl_frac <- tbl_mtcars %>%
    sample_frac(0.2) %>%
    collect() %>%
    count() %>%
    pull()

  expect_lt(tbl_frac, 30)

  expect_error(
    sample_frac(tbl_mtcars, size = 0.5, weight = mpg),
    "`weight` is not supported"
  )
})

test_that("Misc functions", {
  tbl_am <- use_test_table_mtcars() %>%
    group_by(am) %>%
    filter(mpg == max(mpg, na.rm = TRUE)) %>%
    select(am)

  expect_silent(compute(tbl_am, name = "am"))

  expect_silent(compute(tbl_am, name = NULL))

  tbl_join <- use_test_table_mtcars() %>%
    left_join(tbl_am, by = "am") %>%
    arrange(mpg, qsec, hp)

  expect_error(tbl_ptype(tbl_am))

  expect_snapshot(tbl_am[1])

  expect_snapshot(tbl_join)
})

test_that("sdf_copy_to() workks", {
  sc <- use_test_spark_connect()
  test_df <- data.frame(a = 1:1000, b = 1:1000)
  expect_s3_class(
    sdf_copy_to(sc, test_df, name = "test_df"),
    "tbl_pyspark"
  )
  expect_error(
    sdf_copy_to(sc, test_df, name = "test_df"),
    "Temp table test_df already exists, use `overwrite = TRUE` to replace"
  )
  expect_s3_class(
    sdf_copy_to(sc, test_df, name = "test_df", overwrite = TRUE),
    "tbl_pyspark"
  )
  expect_s3_class(
    sdf_copy_to(sc, test_df, name = "test_df", overwrite = TRUE, repartition = 2),
    "tbl_pyspark"
  )
})

test_that("sdf_register() works", {
  tbl_mtcars <- use_test_table_mtcars()
  sc <- use_test_spark_connect()
  obj <- python_sdf(tbl_mtcars)
  py_obj <- as_spark_pyobj(obj, sc)
  expect_s3_class(
    sdf_register(py_obj),
    "tbl_pyspark"
  )
})

test_that("I() works", {
  tbl_mtcars <- use_test_table_mtcars()
  sc <- use_test_spark_connect()
  expect_s3_class({
    tbl(sc, I("mtcars")) %>%
      head() %>%
      collect()
  }, "data.frame")
})
