# DBR error code returns as expected

    Spark connection error
    * Possible cause = The cluster is not running, or not accessible
    * status = StatusCode.UNAVAILABLE
    * details = 'RESOURCE_DOES_NOT_EXIST: No cluster found matching: asdfasdf'

---

    Spark connection error
    * 

# Misc tests

    Code
      allowed_serverless_configs()
    Output
      [1] "spark.sql.legacy.timeParserPolicy" "spark.sql.session.timeZone"       
      [3] "spark.sql.shuffle.partitions"      "spark.sql.ansi.enabled"           

