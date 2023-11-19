test_that("copy_to() works", {
  tbl_ordered <- test_table_mtcars() %>%
    arrange(mpg, qsec, hp)

  expect_snapshot(tbl_ordered)

  expect_snapshot(print(head(tbl_ordered)))
})

test_that("Sampling functions works", {
  tbl_n <- test_table_mtcars() %>%
    sample_n(5) %>%
    collect() %>%
    count() %>%
    pull()

  expect_equal(tbl_n, 5)

  tbl_frac <- test_table_mtcars() %>%
    sample_frac(0.2) %>%
    collect() %>%
    count() %>%
    pull()

  expect_lt(tbl_frac, 30)
})

test_that("Misc functions", {
  tbl_am <- test_table_mtcars() %>%
    group_by(am) %>%
    filter(mpg == max(mpg, na.rm = TRUE)) %>%
    select(am)

  expect_silent(compute(tbl_am, name = "am"))

  tbl_join <- test_table_mtcars() %>%
    left_join(tbl_am, by = "am") %>%
    arrange(mpg, qsec, hp)

  expect_snapshot(tbl_join)
})
