## Package submission

In this version:

* Adds support for `sparklyr::sdf_schema()` and `sparklyr::spark_write_table()`

* Adds `deploy_databricks()` function. It will simplify publishing to Posit
Connect by automating much of the needed setup, and triggers the publication.

* Adds `requirements_write()` function. It will inventory the Python libraries
loaded in a given Python environment and create the 'requirements.txt'. This
is in an effort to make it easier to republish deployed content.

* Improvements to the RStudio connections snippet. It now adapts for when the
host and, or the token, are not available to verify the cluster's DBR version.
If missing, then the snippet will hide the host and token sections, and display
a cluster DBR section so that the user can enter it manually. After entering,
the snippet will verify the installed environment.

* Improves how it process host, token and cluster ID. If it doesn't find a
token, it no longer fails. It will pass nothing for that argument, letting
'databricks.connect' find the token. This allows for Databricks configurations
files to work.

* Prevents failure when the latest 'databricks.connect' version is lower than
the DBR version of the cluster. It will not prompt to install, but rather
alert the user that they will be on a lower version of the library.

* Simplifies to `spark_connect()` connection output.

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

