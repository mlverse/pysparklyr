skip_on_ci()
skip_spark_min_version(4.0)

test_that("Binarizer works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  expect_s3_class(ft_binarizer(sc, "a", "b"), "ml_transformer")
  expect_s3_class(ft_binarizer(ml_pipeline(sc), "a", "b"), "ml_estimator")
  x <- ft_binarizer(tbl_mtcars, "mpg", "mpg_new", threshold = 20)
  expect_s3_class(x, "tbl_pyspark")
  expect_equal(
    dplyr::pull(dplyr::summarise(x, sum(mpg_new, na.rm = TRUE))),
    14
  )
})

test_that("Bucketizer works", {
  sc <- use_test_spark_connect()
  tbl_mtcars <- use_test_table_mtcars()
  expect_s3_class(ft_bucketizer(sc, "a", "b", c(1,2,3)), "ml_transformer")
  expect_s3_class(
    ft_bucketizer(ml_pipeline(sc), "a", "b", c(1,2,3)),
    "ml_estimator"
    )
  x <- ft_bucketizer(tbl_mtcars, "mpg", "mpg_new", splits = c(0, 10, 20, 30, 40))
  expect_s3_class(x, "tbl_pyspark")
  expect_equal(
    dplyr::pull(dplyr::summarise(x, sum(mpg_new, na.rm = TRUE))),
    50
  )
})
