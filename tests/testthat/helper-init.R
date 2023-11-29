.test_env <- new.env()
.test_env$sc <- NULL
.test_env$lr_model <- NULL
.test_env$env <- NULL

use_test_env <-function() {
  if(is.null(.test_env$env)) {
    .test_env$env <- fs::path(tempdir(), random_table_name("env"))
  }
  .test_env$env
}

use_test_version_spark <- function() {
  version <- Sys.getenv("SPARK_VERSION", unset = NA)
  if (is.na(version)) version <- "3.5"
  version
}

use_test_scala_spark <- function() {
  version <- Sys.getenv("SCALA_VERSION", unset = NA)
  if (is.na(version)) version <- "2.12"
  version
}

use_test_spark_connect <- function() {
  if (is.null(.test_env$sc)) {

    env_name <- use_test_python_environment()

    Sys.setenv("PYTHON_VERSION_MISMATCH" = py_exe())
    Sys.setenv("PYSPARK_DRIVER_PYTHON" = py_exe())

    cli_h1("Starting Spark Connect service")
    spark_connect_service_start(
      version = use_test_version_spark(),
      scala_version = use_test_scala_spark()
    )

    cli_h1("Connecting to Spark cluster")
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

use_test_python_environment <- function() {
  spark_version <- use_test_version_spark()
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    {
      env <- use_envname(method = "spark_connect", version = spark_version)
      env_avail <- names(env)
      if(env_avail != "exact") {
        cli_h1("Creating Python environment")
        install_pyspark(version = spark_version, as_job = FALSE, install_ml = FALSE)
        env <- use_envname(method = "spark_connect", version = spark_version)
      }
    })
  env
}
