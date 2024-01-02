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

tests_disable_all <- function() {
  r_scripts <- dir_ls(test_path(), glob = "*.R")
  test_scripts <- r_scripts[substr(path_file(r_scripts), 1, 5) == "test-"]
  map(
    test_scripts, ~{
      ln <- readLines(.x)
      writeLines(c("skip(\"temp\")", ln), con = .x)
    }
  )
}

tests_enable_all <- function() {
  r_scripts <- dir_ls(test_path(), glob = "*.R")
  test_scripts <- r_scripts[substr(path_file(r_scripts), 1, 5) == "test-"]
  map(
    test_scripts, ~{
      ln <- readLines(.x)
      new_ln <- ln[ln != "skip(\"temp\")"]
      writeLines(new_ln, con = .x)
    }
  )
}

test_databricks_cluster_id <- function() {
  Sys.getenv("DATABRICKS_CLUSTER_ID")
}

test_databricks_cluster_version <- function() {
  if(is.null(.test_env$dbr)) {
    dbr <- databricks_dbr_version(
      cluster_id = test_databricks_cluster_id(),
      host = databricks_host(),
      token = databricks_token()
    )
    .test_env$dbr <- dbr
  }
  .test_env$dbr
}

test_databricks_stump_env <- function() {
  env_name <- use_envname(
    version = test_databricks_cluster_version(),
    backend = "databricks"
  )
  if (names(env_name) != "exact") {
    py_install("numpy", env_name, pip = TRUE, python = Sys.which("python"))
  }
  path(reticulate::virtualenv_python(env_name))
}
