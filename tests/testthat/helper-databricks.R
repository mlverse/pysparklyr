skip_if_not_databricks <- function() {
  skip_if(
    inherits(try(databricks_host(), silent = TRUE), "try-error"),
    "No Databricks Host available"
  )
  skip_if(
    inherits(try(databricks_token(), silent = TRUE), "try-error"),
    "No Databricks Token available"
  )
  skip_if(
    is.na(Sys.getenv("DATABRICKS_CLUSTER_ID", unset = NA)),
    "No Databricks Cluster ID available"
  )
}
