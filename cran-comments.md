## Package submission

In this version:

* Adds support for `spark_apply()` via the `rpy2` Python library
  * It will not automatically distribute packages, it will assume that the
  necessary packages are already installed in each node. This also means that
  the `packages` argument is not supported
  * As in its original implementation, schema inferring works, and as with the
  original implementation, it has a performance cost. Unlike the original, the 
  Databricks, and Spark, Connect version will return a 'columns' specification
  that you can use for the next time you run the call.
  
* At connection time, it enables Arrow by default. It does this by setting
these two configuration settings to true: 
  * `spark.sql.execution.arrow.pyspark.enabled`
  * `spark.sql.execution.arrow.pyspark.fallback.enabled`

## Test environments

- Ubuntu 22.04, R 4.3.2, Spark 3.5 (GH Actions)
- Ubuntu 22.04, R 4.3.2, Spark 3.4 (GH Actions)

- Local Mac OS M1 (aarch64-apple-darwin20), R 4.3.2, Spark 3.5 (Local)

## R CMD check environments

- Mac OS M1 (aarch64-apple-darwin20), R 4.3.2 (Local)

- Mac OS x86_64-apple-darwin20.0 (64-bit), R 4.3.2 (GH Actions)
- Windows x86_64-w64-mingw32 (64-bit), R 4.3.2 (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.3.2 (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.4.0 (dev) (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.2.3 (old release) (GH Actions)


## R CMD check results

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

