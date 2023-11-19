.test_env <- new.env()
.test_env$sc <- NULL
.test_env$lr_model <- NULL

test_version_spark <- function() {
  version <- Sys.getenv("SPARK_VERSION", unset = NA)
  if (is.na(version)) version <- "3.4"
  version
}

test_scala_spark <- function() {
  version <- Sys.getenv("SCALA_VERSION", unset = NA)
  if (is.na(version)) version <- "2.12"
  version
}

test_spark_connect <- function() {
  if (is.null(.test_env$sc)) {
    cli_h2("Connecting to Spark cluster")
    .test_env$sc <- sparklyr::spark_connect(
      master = "sc://localhost",
      method = "spark_connect",
      version = test_version_spark()
    )
  }
  .test_env$sc
}

test_table_mtcars <- function() {
  sc <- test_spark_connect()
  if (!"mtcars" %in% dbListTables(sc)) {
    ret <- dplyr::copy_to(sc, mtcars, overwrite = TRUE)
  } else {
    ret <- dplyr::tbl(sc, "mtcars")
  }
  ret
}

test_lr_model <- function() {
  if (is.null(.test_env$lr_model)) {
    tbl_mtcars <- test_table_mtcars()
    .test_env$lr_model <- ml_logistic_regression(tbl_mtcars, am ~ ., max_iter = 10)
  }
  .test_env$lr_model
}

test_coverage_enable <- function() {
  Sys.setenv("CODE_COVERAGE" = "true")
}

expect_same_remote_result <- function(.data, pipeline) {
  sc <- test_spark_connect()
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
  sc <- test_spark_connect()

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
  sc <- test_spark_connect()
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
    lapply(found,
           function(x)
             try(virtualenv_remove(x, confirm = FALSE), silent = TRUE)
           )
    )

  invisible(
    lapply(found,
           function(x)
             try(conda_remove(x), silent = TRUE)
    )
  )
}
