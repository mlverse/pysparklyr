suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(sparklyr))
suppressPackageStartupMessages(library(cli))

## Disconnects all at the end
withr::defer(spark_disconnect_all())
withr::defer(spark_connect_service_stop())
