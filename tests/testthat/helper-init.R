.test_env <- new.env()
.test_env$sc <- NULL
.test_env$lr_model <- NULL
.test_env$env <- NULL
.test_env$started <- NULL
.test_env$dbr <- NULL
.test_env$databricks <- NULL
.test_env$tune_grid <- NULL

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

use_new_temp_env <- function() {
  fs::path(tempdir(), random_table_name("env"))
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

use_test_python_version <- function() {
  version <- Sys.getenv("PYTHON_VERSION", unset = NA)
  if (is.na(version)) version <- "3.10"
  version
}

use_test_connect_start <- function() {
  if (is.null(.test_env$started)) {
    env_path <- use_test_python_environment()
    version <- use_test_version_spark()
    cli_h2("Spark Connect: {version}")
    cli_inform("PYTHON_VERSION_MISMATCH: {env_path}")
    cli_inform("PYSPARK_PYTHON: {env_path}")
    cli_inform("WORKON_HOME: {use_test_env()}")
    cli_inform("SCALA_VERSION: {use_test_scala_spark()}")
    cli_inform("PYTHON_VERSION: {use_test_python_version()}")
    cli_h2("")

    withr::with_envvar(
      new = c(
        "PYSPARK_PYTHON" = env_path,
        "PYTHON_VERSION_MISMATCH" = env_path,
        "PYSPARK_DRIVER_PYTHON" = env_path,
        "PYTHON_VERSION" = use_test_python_version()
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

use_test_table_ovarian <- function() {
  use_test_table(
    x = readRDS(test_path("_data/ovarian.rds")),
    name = "ovarian"
  )
}

use_test_table_iris <- function() {
  sc <- use_test_spark_connect()
  if (!"iris" %in% dbListTables(sc)) {
    ret <- dplyr::copy_to(sc, iris, overwrite = TRUE)
  } else {
    ret <- dplyr::tbl(sc, "iris")
  }
  ret
}

use_test_table <- function(x, name) {
  sc <- use_test_spark_connect()
  if (!name %in% dbListTables(sc)) {
    ret <- dplyr::copy_to(sc, x, name = name, overwrite = TRUE)
  } else {
    ret <- dplyr::tbl(sc, name)
  }
  ret
}

use_test_table_simple <- function() {
  use_test_table(
    x = data.frame(x = c(2, 2, 4, NA, 4), y = 1:5),
    name = "simple_table"
  )
}

use_test_table_reviews <- function() {
  reviews <- data.frame(
    x = "This has been the best TV I've ever used. Great screen, and sound."
  )
  sc <- use_test_spark_connect()
  if (!"reviews" %in% dbListTables(sc)) {
    ret <- dplyr::copy_to(sc, reviews, overwrite = TRUE)
  } else {
    ret <- dplyr::tbl(sc, "reviews")
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
  if (is.null(.test_env$target)) {
    withr::with_envvar(
      new = c("WORKON_HOME" = use_test_env()),
      {
        version <- use_test_version_spark()
        if (use_uv) {
          reticulate::py_require("torch")
          env <- use_envname(
            backend = "pyspark",
            main_library = "pyspark",
            version = version,
            messages = TRUE,
            python_version = use_test_python_version(),
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
              env <- use_envname(
                backend = "pyspark",
                main_library = "pyspark",
                version = version
              )
            }
          }
          target <- path(env, "bin", "python")
        }
      }
    )
    .test_env$target <- target
  }
  .test_env$target
}

use_test_ml_installed <- function() {
  ml_libraries <- pysparklyr_env$ml_libraries
  installed_libraries <- py_list_packages()$package
  find_ml <- map_lgl(ml_libraries, \(.x) .x %in% installed_libraries)
  all(find_ml)
}

use_test_install_ml <- function() {
  if (!use_test_ml_installed()) {
    try(
      py_install(pysparklyr_env$ml_libraries),
      silent = TRUE
    )
    try(
      py_require(pysparklyr_env$ml_libraries),
      silent = TRUE
    )
  }
}

# Needed to ensure `vcr` tests are 100% consistent with the
# cluster number from which they were originally ran from
use_test_db_cluster <- function() {
  return("1117-200943-l1nvd2bl")
}
use_test_db_host <- function() {
  return("https://adb-3256282566390055.15.azuredatabricks.net")
}

skip_ml_missing <- function() {
  skip_if(!use_test_ml_installed(), "ML Python libraries not installed")
}

skip_ml_not_missing <- function() {
  skip_if(use_test_ml_installed(), "ML Python libraries installed")
}
