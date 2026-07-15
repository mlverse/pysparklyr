## Package submission

This is a maintenance release.

* Restores compatibility with sparklyr 1.9.5 / dbplyr 2.6.0, which restructured
the `tbl` source slot (#185).

* Adds support for `tune_grid_spark()`, enabling Tidymodels tune grids to run
inside Spark Connect clusters.

* Snowflake connections now support all native authenticators via the Snowflake
Python SDK, and viewer-based credentials on Posit Connect (#181 - @atheriel).

* Databricks Connect now auto-detects the latest library version from PyPI when
no `version` is specified.

* Fixes conversion of Pandas NULL columns and date types (#178 - @tobiasdut).

## Test environments

- Spark 4: Ubuntu 24.04.3 LTS (x86_64, linux-gnu), R version 4.5.2 (2025-10-31)

- Spark 3: Ubuntu 24.04.3 LTS (x86_64, linux-gnu), R version 4.5.2 (2025-10-31)

## R CMD check environments

- Mac OS M3 (aarch64-apple-darwin23), R 4.5.2 (Local)

- Windows Server 2022 x64 (build 26100) (x86_64, mingw32), R version 4.5.2 (2025-10-31 ucrt)
- macOS Sequoia 15.7.3 (aarch64, darwin20), R version 4.5.2 (2025-10-31)
- Ubuntu 24.04.3 LTS (x86_64, linux-gnu), R Under development (unstable)
- Ubuntu 24.04.3 LTS (x86_64, linux-gnu), R version 4.4.3 (2025-02-28)
- Ubuntu 24.04.3 LTS (x86_64, linux-gnu), R version 4.5.2 (2025-10-31)

## R CMD check results

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
