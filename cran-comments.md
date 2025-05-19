## Package submission

In this version:

* Avoids installing `rpy2` automatically for `uv`-based environments. It will
also install `rpy2` via `py_require()` when `spark_apply()` is called.

* Fixes issue with resetting the connection label (#144)

* Restores Databricks Host name sanitation 

## Test environments

- Ubuntu 24.04, R 4.5.0, Spark 3.5 (GH Actions)

- Local Mac OS M3 (aarch64-apple-darwin23), R 4.4.2, Spark 3.5 (Local)

## R CMD check environments

- Mac OS M3 (aarch64-apple-darwin23), R 4.4.2 (Local)

- Mac OS aarch64-apple-darwin20 (64-bit), R 4.5.0 (GH Actions)
- Windows x86_64-w64-mingw32 (64-bit), R 4.5.0 (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R dev (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.5.0 (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.4.3 (old release) (GH Actions)

## R CMD check results

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

