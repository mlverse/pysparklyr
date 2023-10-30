test_that("Internal functions work", {
  expect_snapshot(.strsep("domino", 3))
  expect_equal(.slice_match("hello", 1), "hello")
  expect_snapshot(.str_split_n("hello", "l", n_max = 3))
  expect_snapshot(.list_indices(c("one", "two", "three"), 2))
  expect_snapshot(.simplify_pieces(c("one", "two", "three"), 2, FALSE))
  expect_warning(.str_split_fixed("hello", "l", 1))
})
