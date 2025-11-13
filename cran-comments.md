## Package submission

* Databricks connections app:
  * Adds a dropdown to the Python Environment to make it more flexible
  * Check for the existence of a Virtual Environment folder inside the
  current RStudio project, adds it to the dropdown choices and makes it the default

* Adds support for spark_write_delta() (#146)

* Gets token from Databricks SDK if one cannot be found. (#148)

## Test environments

- Spark 3.5: Ubuntu 24.04.3 LTS (x86_64, linux-gnu), R version 4.5.1 (2025-06-13)

## R CMD check environments

- Mac OS M3 (aarch64-apple-darwin23), R 4.5.0 (Local)

- Ubuntu 24.04.3 LTS (x86_64, linux-gnu), R Under development (unstable) (2025-10-03 r88899)
- Ubuntu 24.04.3 LTS (x86_64, linux-gnu), R version 4.4.3 (2025-02-28)
- Ubuntu 24.04.3 LTS (x86_64, linux-gnu), R version 4.5.1 (2025-06-13)
- macOS Sequoia 15.6.1 (aarch64, darwin20), R version 4.5.1 (2025-06-13)
- Windows Server 2022 x64 (build 26100) (x86_64, mingw32), R version 4.5.1 (2025-06-13 ucrt)

## R CMD check results

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

