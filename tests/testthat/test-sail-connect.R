skip_if(!use_test_sail(), "SAIL_VERSION is not set")

sail_test_connect <- function() {
  use_test_connect_start()
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    sparklyr::spark_connect(
      master = "local",
      method = "sail",
      version = use_test_version_sail()
    )
  )
}

test_that("Local connections start their own server", {
  sc1 <- sail_test_connect()
  sc2 <- sail_test_connect()
  withr::defer({
    spark_disconnect(sc1)
    spark_disconnect(sc2)
  })
  expect_s3_class(sc1, "connect_sail")
  expect_true(sc1$server$running)
  port1 <- sc1$server$listening_address[[2]]
  port2 <- sc2$server$listening_address[[2]]
  expect_false(port1 == port2)
  expect_equal(sc1$master, glue("Sail - sc://localhost:{port1}"))
  expect_false(python_conn(sc1)$session_id == python_conn(sc2)$session_id)
  copy_to(sc1, mtcars, "only_on_sc1", memory = FALSE)
  expect_true("only_on_sc1" %in% dbListTables(sc1))
  expect_false("only_on_sc1" %in% dbListTables(sc2))
})

test_that("Disconnecting stops the server and closes the pane entry", {
  closed <- NULL
  withr::local_options(connectionObserver = list(
    connectionOpened = function(...) invisible(),
    connectionClosed = function(type, host, ...) closed <<- c(closed, host),
    connectionUpdated = function(...) invisible()
  ))
  sc1 <- sail_test_connect()
  sc2 <- sail_test_connect()
  withr::defer(spark_disconnect(sc2))
  spark_disconnect(sc1)
  expect_false(sc1$server$running)
  expect_true(sc2$server$running)
  expect_length(closed, 1)
  expect_true(startsWith(closed, sc1$master))
})

test_that("`memory = TRUE` and `compute()` are not supported", {
  sc <- sail_test_connect()
  withr::defer(spark_disconnect(sc))
  expect_error(
    copy_to(sc, mtcars),
    "Sail does not support `memory = TRUE`"
  )
  csv <- withr::local_tempfile(fileext = ".csv")
  write.csv(mtcars, csv, row.names = FALSE)
  expect_error(
    spark_read_csv(sc, "cars", csv),
    "Sail does not support `memory = TRUE`"
  )
  tbl_mtcars <- copy_to(sc, mtcars, memory = FALSE)
  expect_error(
    compute(tbl_mtcars),
    "Sail does not support `compute\\(\\)`"
  )
})

test_that("`copy_to(memory = FALSE)` names the table and checks `overwrite`", {
  sc <- sail_test_connect()
  withr::defer(spark_disconnect(sc))
  copy_to(sc, mtcars, memory = FALSE)
  expect_true("mtcars" %in% dbListTables(sc))
  expect_equal(dplyr::pull(dplyr::count(dplyr::tbl(sc, "mtcars")), n), 32)
  expect_error(
    copy_to(sc, mtcars, memory = FALSE),
    "already exists"
  )
  copy_to(sc, head(mtcars), "mtcars", memory = FALSE, overwrite = TRUE)
  expect_equal(dplyr::pull(dplyr::count(dplyr::tbl(sc, "mtcars")), n), 6)
})
