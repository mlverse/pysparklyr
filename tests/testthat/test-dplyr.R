test_that("copy_to() works", {
  sc <- test_spark_connect()

  expect_silent(
    tbl_mtcars <- copy_to(sc, mtcars, overwrite = TRUE)
  )

  tbl_ordered <- tbl_mtcars %>%
    arrange(mpg)

  expect_snapshot(tbl_ordered)

  expect_snapshot(print(head(tbl_mtcars)))

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

  tbl_am <- tbl_mtcars %>%
    group_by(am) %>%
    filter(mpg == max(mpg, na.rm = TRUE)) %>%
    select(am)

  expect_silent(compute(tbl_am, name = "am"))

  tbl_join <- tbl_mtcars %>%
    left_join(tbl_am, by = "am") %>%
    arrange(mpg)

  expect_snapshot(tbl_join)
})
