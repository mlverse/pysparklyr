.test_env <- new.env()
.test_env$sc <- NULL
.test_env$lr_model <- NULL

use_test_version_spark <- function() {
  version <- Sys.getenv("SPARK_VERSION", unset = NA)
  if (is.na(version)) version <- "3.4"
  version
}

use_test_scala_spark <- function() {
  version <- Sys.getenv("SCALA_VERSION", unset = NA)
  if (is.na(version)) version <- "2.12"
  version
}

use_test_spark_connect <- function() {
  if (is.null(.test_env$sc)) {
    cli_h2("Connecting to Spark cluster")
    .test_env$sc <- sparklyr::spark_connect(
      master = "sc://localhost",
      method = "spark_connect",
      version = use_test_version_spark()
    )
  }
  .test_env$sc
}

use_test_table_mtcars <- function() {
  sc <- use_test_spark_connect()
  if (!"mtcars" %in% dbListTables(sc)) {
    ret <- dplyr::copy_to(sc, mtcars, overwrite = TRUE)
  } else {
    ret <- dplyr::tbl(sc, "mtcars")
  }
  ret
}

use_test_lr_model <- function() {
  if (is.null(.test_env$lr_model)) {
    tbl_mtcars <- use_test_table_mtcars()
    .test_env$lr_model <- ml_logistic_regression(tbl_mtcars, am ~ ., max_iter = 10)
  }
  .test_env$lr_model
}
