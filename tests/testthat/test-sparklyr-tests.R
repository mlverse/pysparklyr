test_that("Spark Integ works", {
  sc <- use_test_spark_connect()
  expect_true(spark_integ_test_skip(sc, "test"))
})
