skip_on_ci()
skip_spark_min_version(4.0)

test_that("Binarizer works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  expect_snapshot(class(ft_binarizer(sc, "a", "b")))
  expect_snapshot(class(ft_binarizer(ml_pipeline(sc), "a", "b")))
  x <- ft_binarizer(tbl_mtcars, "mpg", "mpg_new", threshold = 20)
  expect_snapshot(class(x))
  expect_equal(
    dplyr::pull(dplyr::summarise(x, sum(mpg_new, na.rm = TRUE))),
    14
  )
})

test_that("Bucketizer works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  expect_snapshot(class(ft_bucketizer(sc, "a", "b", c(1, 2, 3))))
  expect_snapshot(class(ft_bucketizer(ml_pipeline(sc), "a", "b", c(1, 2, 3))))
  x <- ft_bucketizer(tbl_mtcars, "mpg", "mpg_new", splits = c(0, 10, 20, 30, 40))
  expect_snapshot(class(x))
  expect_equal(
    dplyr::pull(dplyr::summarise(x, sum(mpg_new, na.rm = TRUE))),
    50
  )
})

test_that("R Formula works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  expect_snapshot(class(ft_r_formula(ml_pipeline(sc))))
  expect_snapshot(class(ft_r_formula(sc)))
  expect_snapshot(
    ft_r_formula(
      tbl_mtcars,
      mpg ~ .,
      features_col = "test"
    ) %>%
      colnames()
  )
})
