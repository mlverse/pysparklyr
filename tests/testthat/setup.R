suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(sparklyr))
suppressPackageStartupMessages(library(cli))

cli_h2("Starting Spark Connect service")
spark_connect_service_start(
  version = test_version_spark(),
  scala_version = test_scala_spark()
)

## Disconnects all at the end
withr::defer(spark_disconnect_all(), teardown_env())
withr::defer(
  spark_connect_service_stop(test_version_spark()),
  teardown_env()
)
