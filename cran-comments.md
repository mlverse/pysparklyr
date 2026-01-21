## Package submission

This is a minor version release with several important improvements:

* Adds support for Snowflake's Snowpark Connect
* Adds support for new ML methodology implemented in Spark 4.0, including 60+ new ML functions and transformers
* Fixes issues with Databricks OAuth token retrieval in Posit Workbench
* Tests now use `uv` for Python environment setup

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

