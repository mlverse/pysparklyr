suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(sparklyr))
suppressPackageStartupMessages(library(cli))

## Clean up at end
withr::defer({
  # Disconnecting from Spark
  withr::defer(spark_disconnect_all(), envir = rlang::global_env())
  # Stopping Spark Connect service
  withr::defer(spark_connect_service_stop(), envir = rlang::global_env())
  # Deleting main Python environment
  withr::defer(fs::dir_delete(use_test_env()), envir = rlang::global_env())
})
