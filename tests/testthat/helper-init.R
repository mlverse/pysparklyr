.test_env <- new.env()
.test_env$sc <- NULL

test_version_spark <- function() {
  version <- Sys.getenv("SPARK_VERSION", unset = NA)
  if(is.na(version)) version <- "3.4"
  version
}

test_scala_spark <- function() {
  version <- Sys.getenv("SCALA_VERSION", unset = NA)
  if(is.na(version)) version <- "2.12"
  version
}

test_spark_connect <- function() {
  if(is.null(.test_env$sc)) {
    .test_env$sc <- sparklyr::spark_connect(
      master = "sc://localhost",
      method = "spark_connect",
      version = test_version_spark()
    )
  }
  .test_env$sc
}

test_coverage_enable <-  function() {
  Sys.setenv("CODE_COVERAGE" = "true")
}
