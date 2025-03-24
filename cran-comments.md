## Package submission

In this version:

* Adding support for Databricks serverless interactive compute (#127)

* Extended authentication method support for Databricks by deferring to SDK (#127)

* Adds support for new way `reticulate` manages Python environments
(https://rstudio.github.io/reticulate/articles/package.html). This means that 
the need to run `install_pyspark()` or `install_databricks()` will not be 
needed for interactive R sessions. 

* Adds limited support for `context` in `spark_apply()`. It will only work when
`group_by` is used. The object passed to `context` cannot be an R `list`

* Adjusted logic for handling config to now warn users when unsupported configs
are supplied if using Databricks serverless compute

* Disables un-setting the `RETICULATE_PYTHON` environment variable. It will
still display a warning if it's set, letting the user know that it may 
cause connectivity issues.

* Databricks connections should now correctly use `databricks_host()`

## Test environments

- Ubuntu 24.04, R 4.4.3, Spark 3.5 (GH Actions)

- Local Mac OS M3 (aarch64-apple-darwin23), R 4.4.2, Spark 3.5 (Local)

## R CMD check environments

- Mac OS M3 (aarch64-apple-darwin23), R 4.4.0 (Local)

- Mac OS x86_64-apple-darwin20.0 (64-bit), R 4.4.3 (GH Actions)
- Windows x86_64-w64-mingw32 (64-bit), R 4.4.3 (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R dev (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.4.3 (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.3.3 (old release) (GH Actions)

## R CMD check results

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

