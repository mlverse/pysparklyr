test_that("Pivot longer", {
  sc <- use_test_spark_connect()
  local_pivot <- tibble::tribble(
    ~id , ~z_1 , ~y_1 , ~x_1 , ~z_2 , ~y_2 , ~x_2 ,
    "A" ,    1 ,    2 ,    3 ,    4 ,    5 ,    6 ,
    "B" ,    7 ,    8 ,    9 ,   10 ,   11 ,   12 ,
  )
  tbl_pivot <- copy_to(sc, local_pivot)

  expect_snapshot(
    tbl_pivot %>%
      tidyr::pivot_longer(
        -id,
        names_to = c(".value", "n"),
        names_sep = "_"
      ) %>%
      collect()
  )
})

trivial_sdf <- testthat_tbl(
  "testthat_tidyr_pivot_longer_trivial_sdf",
  data = tibble::tibble(x_y = 1)
)

test_that("can pivot all cols to long", {
  expect_same_remote_result(
    tibble::tibble(x = 1:2, y = 3:4),
    function(.x) .x |> tidyr::pivot_longer(x:y)
  )
})

test_that("values interleaved correctly", {
  expect_same_remote_result(
    tibble::tibble(x = c(1, 2), y = c(10, 20), z = c(100, 200)),
    function(.x) .x |> tidyr::pivot_longer(1:3)
  )
})

test_that("can drop missing values", {
  expect_same_remote_result(
    tibble::tibble(x = c(1, NA), y = c(NA, 2)),
    function(.x) .x |> tidyr::pivot_longer(x:y, values_drop_na = TRUE)
  )
})

test_that("preserves original keys", {
  expect_same_remote_result(
    tibble::tibble(x = 1:2, y = 2L, z = 1:2),
    function(.x) .x |> tidyr::pivot_longer(y:z)
  )
})

test_that("can handle missing combinations", {
  expect_same_remote_result(
    tibble::tribble(
      ~id , ~x_1 , ~x_2 , ~y_2 ,
      "A" ,    1 ,    2 , "a"  ,
      "B" ,    3 ,    4 , "b"  ,
    ),
    function(.x) {
      .x |>
        tidyr::pivot_longer(
          -id,
          names_to = c(".value", "n"),
          names_sep = "_"
        )
    }
  )
})

test_that("original col order is preserved", {
  expect_same_remote_result(
    tibble::tribble(
      ~id , ~z_1 , ~y_1 , ~x_1 , ~z_2 , ~y_2 , ~x_2 ,
      "A" ,    1 ,    2 ,    3 ,    4 ,    5 ,    6 ,
      "B" ,    7 ,    8 ,    9 ,   10 ,   11 ,   12 ,
    ),
    function(.x) {
      .x |>
        tidyr::pivot_longer(
          -id,
          names_to = c(".value", "n"),
          names_sep = "_"
        )
    }
  )
})

test_that("can pivot duplicated names to .value", {
  expect_same_remote_result(
    tibble::tibble(x = 1, a_1 = 1, a_2 = 2, b_1 = 3, b_2 = 4),
    function(.x) {
      .x |> tidyr::pivot_longer(-x, names_to = c(".value", NA), names_sep = "_")
    }
  )

  expect_same_remote_result(
    tibble::tibble(x = 1, a_1 = 1, a_2 = 2, b_1 = 3, b_2 = 4),
    function(.x) {
      .x |>
        tidyr::pivot_longer(
          -x,
          names_to = c(".value", NA),
          names_pattern = "(.)_(.)"
        )
    }
  )

  expect_same_remote_result(
    tibble::tibble(x = 1, a_1 = 1, a_2 = 2, b_1 = 3, b_2 = 4),
    function(.x) {
      .x |>
        tidyr::pivot_longer(-x, names_to = ".value", names_pattern = "(.)_.")
    }
  )
})

test_that(".value can be at any position in `names_to`", {
  sc <- use_test_spark_connect()
  samp_sdf <- copy_to(
    sc,
    tibble::tibble(
      i = 1:4,
      y_t1 = rnorm(4),
      y_t2 = rnorm(4),
      z_t1 = rep(3, 4),
      z_t2 = rep(-2, 4)
    )
  )
  samp_sdf2 <- dplyr::rename(
    samp_sdf,
    t1_y = y_t1,
    t2_y = y_t2,
    t1_z = z_t1,
    t2_z = z_t2
  )

  pv <- lapply(
    list(
      tidyr::pivot_longer(
        samp_sdf,
        -i,
        names_to = c(".value", "time"),
        names_sep = "_"
      ),
      tidyr::pivot_longer(
        samp_sdf2,
        -i,
        names_to = c("time", ".value"),
        names_sep = "_"
      )
    ),
    collect
  )

  expect_identical(pv[[1]], pv[[2]])
})

test_that("reporting data type mismatch", {
  sc <- use_test_spark_connect()
  sdf <- copy_to(sc, tibble::tibble(abc = 1, xyz = "b"))
  err <- capture_error(tidyr::pivot_longer(sdf, tidyr::everything()))

  expect_true(grepl("data type mismatch", err$message, fixed = TRUE))
})

test_that("grouping is preserved", {
  expect_same_remote_result(
    tibble::tibble(g = 1, x1 = 1, x2 = 2),
    function(.x) {
      .x |>
        dplyr::group_by(g) %>%
        tidyr::pivot_longer(x1:x2, names_to = "x", values_to = "v")
    }
  )
})
