test_coverage_enable <- function() {
  Sys.setenv("CODE_COVERAGE" = "true")
}

expect_same_remote_result <- function(.data, pipeline) {
  sc <- use_test_spark_connect()
  temp_name <- random_table_name("test_")
  spark_data <- copy_to(sc, .data, temp_name)

  local <- pipeline(.data)

  remote <- try(
    spark_data %>%
      pipeline() %>%
      collect()
  )

  if (inherits(remote, "try-error")) {
    expect_equal(remote[[1]], "")
  } else {
    expect_equal(local, remote, ignore_attr = TRUE)
  }

  DBI::dbRemoveTable(sc, temp_name)
}

testthat_tbl <- function(name, data = NULL, repartition = 0L) {
  sc <- use_test_spark_connect()

  tbl <- tryCatch(dplyr::tbl(sc, name), error = identity)
  if (inherits(tbl, "error")) {
    if (is.null(data)) data <- eval(as.name(name), envir = parent.frame())
    tbl <- dplyr::copy_to(sc, data, name = name, repartition = repartition)
  }

  tbl
}

random_table_name <- function(prefix) {
  paste0(prefix, paste0(floor(runif(10, 0, 10)), collapse = ""))
}


skip_spark_min_version <- function(version) {
  sc <- use_test_spark_connect()
  sp_version <- spark_version(sc)
  comp_ver <- compareVersion(as.character(version), sp_version)
  if (comp_ver != -1) {
    skip(glue("Skips on Spark version {version}"))
  }
}


test_remove_python_envs <- function(x = "") {
  found <- find_environments(x)
  cli_inform("Environments found: {length(found)}")

  invisible(
    lapply(
      found,
      function(x) {
        try(virtualenv_remove(x, confirm = FALSE), silent = TRUE)
      }
    )
  )

  invisible(
    lapply(
      found,
      function(x) {
        try(conda_remove(x), silent = TRUE)
      }
    )
  )
}
