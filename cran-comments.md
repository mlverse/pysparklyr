## Package submission

* Adds URL sanitation routine for the Databricks Host. It will remove trailing
forward slashes, and add scheme (https) if missing. The Host sanitation can be 
skipped by passing `host_sanitize = FALSE` to `spark_connect()`.

* Suppresses targeted warning messages coming from Python. Specifically, 
deprecation warnings given to PySpark by Pandas for two variable types:
`is_datetime64tz_dtype`, and `is_categorical_dtype`

* Defaults Python environment creation and installation to run as an RStudio
job if the user is within the RStudio IDE. This feature can be overriden
using the new `as_job` argument inside `install_databricks()`, and 
`install_pyspark()` functions

* Uses SQL to pull the tree structure that populates the RStudio Connections
Pane. This avoids fixing the current catalog and database multiple times,
which causes delays. With SQL, we can just pass the Catalog and/or Database
directly in the query. 

* `installed_components()` now displays the current version of `reticulate` in
the R session

* Adds handling of `RETICULATE_PYTHON` flag 

* Fixes `Error: Unable to find conda binary. Is Anaconda installed?` error (#48)

* Improves error messages when installing, and connecting to Databricks (#44 #45)

## Test environments

- Ubuntu 22.04, R 4.3.2, Spark 3.5 (GH Actions)
- Ubuntu 22.04, R 4.3.2, Spark 3.4 (GH Actions)

- Local Mac OS M1 (aarch64-apple-darwin20), R 4.3.1, Spark 3.5 (Local)

## R CMD check environments

- Mac OS M1 (aarch64-apple-darwin20), R 4.3.1 (Local)

- Mac OS x86_64-apple-darwin20.0 (64-bit), R 4.3.2 (GH Actions)
- Windows  x86_64-w64-mingw32 (64-bit), R 4.3.2 (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.3.2 (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.4.0 (dev) (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.2.3 (old release) (GH Actions)


## R CMD check results

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

