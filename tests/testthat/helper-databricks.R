skip_if_not_databricks <- function() {
  if (!is.null(.test_env$databricks)) {
    skip_if(.test_env$databricks)
  }
  skip_if_no_db_host()
  skip_if_no_db_token()
  skip_if_no_db_cluster_id()
}

skip_if_no_db_cluster_id <- function() {
  cluster_id <- Sys.getenv("DATABRICKS_CLUSTER_ID", unset = NA)
  skip_if(
    is.na(cluster_id),
    "No Databricks Cluster ID available"
  )
  skip_if_no_db_host()
  skip_if_no_db_token()
  bad_dbr <- inherits(
    try(
      databricks_dbr_info(
        cluster_id = cluster_id,
        host = Sys.getenv("DATABRICKS_HOST"),
        token = Sys.getenv("DATABRICKS_TOKEN")
      ),
      silent = TRUE
    ),
    "try-error"
  )
  .test_env$databricks <- bad_dbr
  skip_if(bad_dbr, "Cluster could not be contacted")
}

skip_if_no_db_host <- function() {
  skip_if(
    !nzchar(Sys.getenv("DATABRICKS_HOST")),
    "No Databricks Host available"
  )
}

skip_if_no_db_token <- function() {
  skip_if_no_db_host()
  skip_if(
    !nzchar(Sys.getenv("DATABRICKS_TOKEN")),
    "No Databricks Token available"
  )
}
