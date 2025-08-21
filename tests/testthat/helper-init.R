.test_env <- new.env()
.test_env$sc <- NULL
.test_env$lr_model <- NULL
.test_env$env <- NULL
.test_env$started <- NULL
.test_env$dbr <- NULL
.test_env$databricks <- NULL

use_test_env <- function() {
  if (is.null(.test_env$env)) {
    .test_env$env <- use_new_test_env()
  }
  .test_env$env
}

use_new_test_env <- function() {
  base <- fs::path_expand("~/test-spark")
  x <- fs::path(base, random_table_name("env"))
  fs::dir_create(x)
}

use_test_version_spark <- function() {
  version <- Sys.getenv("SPARK_VERSION", unset = NA)
  if (is.na(version)) version <- "4.0"
  version
}

use_test_scala_spark <- function() {
  version <- Sys.getenv("SCALA_VERSION", unset = NA)
  if (is.na(version)) version <- "2.13"
  version
}

use_test_connect_start <- function() {
  if (is.null(.test_env$started)) {
    env_path <- use_test_python_environment()
    version <- use_test_version_spark()
    cli_h1("Starting Spark Connect service version {version}")
    cli_h3("PYTHON_VERSION_MISMATCH: {env_path}")
    cli_h3("PYSPARK_PYTHON: {env_path}")
    cli_h3("WORKON_HOME: {use_test_env()}")
    withr::with_envvar(
      new = c(
        "PYSPARK_PYTHON" = env_path,
        "PYTHON_VERSION_MISMATCH" = env_path,
        "PYSPARK_DRIVER_PYTHON" = env_path
      ),
      {
        spark_connect_service_start(
          version = version,
          scala_version = use_test_scala_spark()
        )
      }
    )
    .test_env$started <- 0
    cli_inform("-- Waiting a couple of seconds to let the service start")
    Sys.sleep(2)
    cli_inform("-- Done")
  } else {
    invisible()
  }
}

use_test_spark_connect <- function() {
  if (is.null(.test_env$sc)) {
    conf <- pyspark_config()
    conf$spark.python.worker.memory <- "50m"
    use_test_connect_start()
    cli_h1("Connecting to Spark cluster")
    withr::with_envvar(
      new = c(
        "WORKON_HOME" = use_test_env(),
        "PYSPARK_PYTHON" = use_test_python_environment(),
        "PYTHON_VERSION_MISMATCH" = use_test_python_environment(),
        "PYSPARK_DRIVER_PYTHON" = use_test_python_environment()
      ),
      {
        .test_env$sc <- sparklyr::spark_connect(
          master = "sc://localhost",
          method = "spark_connect",
          version = use_test_version_spark(),
          config = conf,
          envname = use_test_python_environment()
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

use_test_python_environment <- function(use_uv = TRUE) {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    {
      version <- use_test_version_spark()
      if (use_uv) {
        env <- use_envname(
          backend = "pyspark",
          version = version,
          messages = TRUE,
          ask_if_not_installed = FALSE
        )
        reticulate::import("pyspark")
        target <- reticulate::py_exe()
      } else {
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
            env <- use_envname(backend = "pyspark", version = version)
          }
        }
        target <- path(env, "bin", "python")
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
  if (!use_test_ml_installed()) {
    py_install(pysparklyr_env$ml_libraries)
  }
}

skip_ml_missing <- function() {
  skip_if(!use_test_ml_installed(), "ML Python libraries not installed")
}

skip_ml_not_missing <- function() {
  skip_if(use_test_ml_installed(), "ML Python libraries installed")
}
