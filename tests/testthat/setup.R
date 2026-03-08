suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(sparklyr))
suppressPackageStartupMessages(library(cli))

## Clean up at end
withr::defer({
  # Disconnecting from Spark
  try(spark_disconnect_all(), silent = TRUE)

  # Stopping Spark Connect service
  try(spark_connect_service_stop(use_test_version_spark()), silent = TRUE)

  # Kill process if still running
  if (exists("spark_connect_process", envir = .GlobalEnv)) {
    prs <- get("spark_connect_process", envir = .GlobalEnv)
    if (prs$is_alive()) {
      try(prs$kill(), silent = TRUE)
    }
    rm("spark_connect_process", envir = .GlobalEnv)
  }

  # Deleting main Python environment (commented out as it may be too aggressive)
  # try(fs::dir_delete(use_test_env()), silent = TRUE)
}, testthat::teardown_env())
