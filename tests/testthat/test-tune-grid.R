test_that("tune_grid_spark() works - resamples", {
  x <- use_tune_grid()
  sc <- use_test_spark_connect()
  spark_results <- tune_grid_spark(
    sc = sc,
    object = x$object,
    preprocessor = x$preprocessor,
    resamples = x$resamples,
    grid = x$grid,
    control = x$control
  )
  local_results <- tune::tune_grid(
    object = x$object,
    preprocessor = x$preprocessor,
    resamples = x$resamples,
    grid = x$grid,
    control = x$control
  )
  expect_equal(colnames(local_results), colnames(spark_results))
  expect_equal(local_results[, 1:4], spark_results[, 1:4])
})

test_that("tune_grid_spark() works - everything", {
  x <- use_tune_grid()
  sc <- use_test_spark_connect()
  cntrl <- tune::control_grid(parallel_over = "everything")
  spark_results <- tune_grid_spark(
    sc = sc,
    object = x$object,
    preprocessor = x$preprocessor,
    resamples = x$resamples,
    grid = x$grid,
    control = cntrl
  )
  local_results <- tune::tune_grid(
    object = x$object,
    preprocessor = x$preprocessor,
    resamples = x$resamples,
    grid = x$grid,
    control = cntrl
  )
  expect_equal(colnames(local_results), colnames(spark_results))
  expect_equal(local_results[, 1:4], spark_results[, 1:4])
})

test_that("loop_predictions works", {
  expect_null(
    loop_predictions(data.frame(path = "test", index = 1))
  )

  expect_equal(
    loop_predictions(
      data.frame(path = test_path("_data/ovarian.rds"), index = 1)
    ),
    test_path("_data/ovarian.rds") |>
      readRDS() |>
      dplyr::mutate(index = 1)
  )
})

test_that("loop_call works", {
  x <- use_tune_grid()
  grid <- x$grid
  resamples <- x$resamples
  prepped <- prep_static(
    object = x$object,
    preprocessor = x$preprocessor,
    resamples = resamples,
    grid = x$grid,
    control = x$control,
    call = rlang::caller_env()
  )
  if (all(resamples$id == "train/test split")) {
    resamples$.seeds <- map(resamples$id, \(x) integer(0))
  } else {
    resamples$.seeds <- tune::get_parallel_seeds(nrow(resamples))
  }
  vec_resamples <- resamples |>
    vctrs::vec_split(by = 1:nrow(resamples)) |>
    _$val
  temp_dir <- fs::path_temp()
  saveRDS(prepped$static, file.path(temp_dir, "static.rds"))
  saveRDS(vec_resamples, file.path(temp_dir, "resamples.rds"))
  withr::with_envvar(
    new = c("TEMP_SPARK_GRID" = temp_dir),
    {
      library(tune)
      res <- loop_call(data.frame(index = 1))
    }
  )
  expect_s3_class(res, "data.frame")
})
