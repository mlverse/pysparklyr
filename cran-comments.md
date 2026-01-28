## Package submission

* Adds support for Pandas 3.0 conversion (#169)

* Properly converts Pandas columns to R (#165 - @romangehrn) 

* Switches to using the configuration file in Posit Workbench to obtain the
Databricks OAuth token. This guarantees that RMarkdown and Quarto documents
that attempt to access a Databricks cluster are successful (#166)

* Adds support for Databricks Viewer OAuth credentials. 

* Adds support for Snowflake's Snowpark Connect. New method name is `snowpark_connect`.

* Adds support for new ML methodology implemented in Spark 4.0 (#153). 

* Tests switch over to using `uv` for setup (internal)

## Test environments

- Spark 4: Ubuntu 24.04.3 LTS (x86_64, linux-gnu), R version 4.5.2 (2025-10-31)

- Spark 3: Ubuntu 24.04.3 LTS (x86_64, linux-gnu), R version 4.5.2 (2025-10-31)

## R CMD check environments

- Mac OS M3 (aarch64-apple-darwin23), R 4.5.2 (Local)

- Windows Server 2022 x64 (build 26100) (x86_64, mingw32), R version 4.5.2 (2025-10-31 ucrt)
- macOS Sequoia 15.7.3 (aarch64, darwin20), R version 4.5.2 (2025-10-31)
- Ubuntu 24.04.3 LTS (x86_64, linux-gnu), R Under development (unstable) (2026-01-21 r89314)
- Ubuntu 24.04.3 LTS (x86_64, linux-gnu), R version 4.4.3 (2025-02-28)
- Ubuntu 24.04.3 LTS (x86_64, linux-gnu), R version 4.5.2 (2025-10-31)

## R CMD check results

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

