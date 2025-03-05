## Package submission

In this version:

* Adds IDE check for positron (#121)

* No longer install 'rpy2' by default. It will prompt user for installation
the first time `spark_apply()` is called (#125)

* Fixes error returned by `httr2` to sanitize the Databricks Host URL (#130)

* Fixes issues with catalog and schema names with dashes in the Connections
Pane. 

* Avoids failure when an unexpected error from Databricks is returned (#123)

## Test environments

- Ubuntu 24.04, R 4.4.2, Spark 3.5 (GH Actions)
- Ubuntu 24.04, R 4.4.2, Spark 3.4 (GH Actions)

- Local Mac OS M3 (aarch64-apple-darwin23), R 4.4.1, Spark 3.5 (Local)

## R CMD check environments

- Mac OS M3 (aarch64-apple-darwin23), R 4.4.0 (Local)

- Mac OS x86_64-apple-darwin20.0 (64-bit), R 4.4.2 (GH Actions)
- Windows x86_64-w64-mingw32 (64-bit), R 4.4.2 (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R dev (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.4.2 (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.3.3 (old release) (GH Actions)


## R CMD check results

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

