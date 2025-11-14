# DBR error code returns as expected

    Code
      databricks_dbr_error(error)
    Condition
      Error in `databricks_dbr_error()`:
      ! Spark connection error
      * Possible cause = The cluster is not running, or not accessible
      * status = StatusCode.UNAVAILABLE
      * details = 'RESOURCE_DOES_NOT_EXIST: No cluster found matching: asdfasdf'

---

    Code
      databricks_dbr_error("")
    Condition
      Error in `databricks_dbr_error()`:
      ! Spark connection error
      * 

# Misc tests

    Code
      allowed_serverless_configs()
    Output
      [1] "spark.sql.legacy.timeParserPolicy" "spark.sql.session.timeZone"       
      [3] "spark.sql.shuffle.partitions"      "spark.sql.ansi.enabled"           

