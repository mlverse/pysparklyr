## Package submission

In this version:

* Adds support for `I()` in `tbl()`

* Ensures `arrow` is installed by adding it to Imports (#116)

* If the cluster version is higher than the available Python library, it will
either use, or offer to install the available Python library

* Fixes issues with having multiple line functions in `spark_apply()`

## Test environments

- Ubuntu 22.04, R 4.4.1, Spark 3.5 (GH Actions)
- Ubuntu 22.04, R 4.4.1, Spark 3.4 (GH Actions)

- Local Mac OS M3 (aarch64-apple-darwin23), R 4.4.0, Spark 3.5 (Local)

## R CMD check environments

- Mac OS M3 (aarch64-apple-darwin23), R 4.4.0 (Local)

- Mac OS x86_64-apple-darwin20.0 (64-bit), R 4.4.1 (GH Actions)
- Windows x86_64-w64-mingw32 (64-bit), R 4.4.1 (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R dev (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.4.1 (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.3.3 (old release) (GH Actions)


## R CMD check results

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

