.test_env <- new.env()
.test_env$sc <- NULL
.test_env$lr_model <- NULL
.test_env$env <- NULL
.test_env$started <- NULL

use_test_env <- function() {
  if (is.null(.test_env$env)) {
    base <- fs::path_expand("~/test-spark")
    .test_env$env <- fs::path(base, random_table_name("env"))
    fs::dir_create(.test_env$env)
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

use_test_connect_start <- function() {
  if (is.null(.test_env$started)) {
    env_path <- path(use_test_python_environment(), "bin", "python")
    version <- use_test_version_spark()
    Sys.setenv("PYTHON_VERSION_MISMATCH" = env_path)
    Sys.setenv("PYSPARK_DRIVER_PYTHON" = env_path)
    cli_h1("Starting Spark Connect service version {version}")
    cli_h3("PYTHON_VERSION_MISMATCH: {Sys.getenv('PYTHON_VERSION_MISMATCH')}")
    cli_h3("PYSPARK_DRIVER_PYTHON: {Sys.getenv('PYSPARK_DRIVER_PYTHON')}")
    spark_connect_service_start(
      version = version,
      scala_version = use_test_scala_spark()
    )
    .test_env$started <- 0
  } else {
    invisible()
  }
}

use_test_spark_connect <- function() {
  if (is.null(.test_env$sc)) {
    use_test_connect_start()
    cli_h1("Connecting to Spark cluster")
    withr::with_envvar(
      new = c("WORKON_HOME" = use_test_env()),
      {
        .test_env$sc <- sparklyr::spark_connect(
          master = "sc://localhost",
          method = "spark_connect",
          version = use_test_version_spark()
        )
      }
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
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    {
      version <- use_test_version_spark()
      env <- use_envname(method = "spark_connect", version = version)
      env_avail <- names(env)
      target <- path(use_test_env(), env)
      if (!dir_exists(target)) {
        if (env_avail != "exact") {
          cli_h1("Creating Python environment")
          install_pyspark(
            version = version,
            as_job = FALSE,
            python = Sys.which("python"),
            install_ml = FALSE
          )
          env <- use_envname(method = "spark_connect", version = version)
        }
      }
    }
  )
  target
}

use_test_ml_installed <- function() {
  ml_libraries <- pysparklyr_env$ml_libraries
  installed_libraries <- py_list_packages()$package
  find_ml <- map_lgl(ml_libraries, ~ .x %in% installed_libraries)
  all(find_ml)
}

use_test_install_ml <- function() {
  if(!use_test_ml_installed()) {
    py_install(pysparklyr_env$ml_libraries)
  }
}

skip_ml_missing <- function() {
  skip_if(!use_test_ml_installed(), "ML Python libraries not installed")
}

skip_ml_not_missing <- function() {
  skip_if(use_test_ml_installed(), "ML Python libraries installed")
}
