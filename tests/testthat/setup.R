suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(sparklyr))
suppressPackageStartupMessages(library(cli))

## Clean up at end
# withr::defer({
# Disconnecting from Spark
# withr::defer(spark_disconnect_all(), teardown_env())
# Stopping Spark Connect service
# withr::defer(pysparklyr::spark_connect_service_stop("4.0.1"))
# Deleting main Python environment
# withr::defer(fs::dir_delete(use_test_env()), teardown_env())
# })
