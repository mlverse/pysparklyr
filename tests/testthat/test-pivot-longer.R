test_that("Pivot longer", {
  sc <- test_spark_connect()
  local_pivot <- tibble::tribble(
    ~id, ~z_1, ~y_1, ~x_1, ~z_2, ~y_2, ~x_2,
    "A", 1, 2, 3, 4, 5, 6,
    "B", 7, 8, 9, 10, 11, 12,
  )
  tbl_pivot <- copy_to(sc, local_pivot)

  expect_snapshot(
    tbl_pivot %>%
      tidyr::pivot_longer(
        -id,
        names_to = c(".value", "n"), names_sep = "_"
      )
  )
})
