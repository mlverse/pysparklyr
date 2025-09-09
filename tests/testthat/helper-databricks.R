skip_if_not_databricks <- function() {
  if (!is.null(.test_env$databricks)) {
    skip_if(.test_env$databricks)
  }
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
  bad_dbr <- inherits(
    try(
      databricks_dbr_info(
        cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID", unset = NA),
        host = databricks_host(),
        token = databricks_token()
      ),
      silent = TRUE
    ),
    "try-error"
  )
  .test_env$databricks <- bad_dbr
  skip_if(bad_dbr, "Cluster could not be contacted")
}

skip_if_no_cluster_id <- function() {
  skip_if(
    is.na(Sys.getenv("DATABRICKS_CLUSTER_ID", unset = NA)),
    "No Databricks Cluster ID available"
  )
}
