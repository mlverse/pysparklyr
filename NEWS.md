# pysparklyr (Development)

### Machine Learning

* Adds support for: 
  - `ft_standard_scaler()`
  - `ft_max_abs_scaler()`
  - `ml_logistic_regression()`
  - `ml_pipeline()`
  - `ml_save()`
  - `ml_predict()`
  - `ml_transform()`

- Adds `ml_prepare_dataset()` in lieu of a Vector Assembler transformer

# pysparklyr 0.1.1

### Improvements

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

### Diagnostics 

* `installed_components()` now displays the current version of `reticulate` in
the R session

* Adds handling of `RETICULATE_PYTHON` flag 

* Fixes `Error: Unable to find conda binary. Is Anaconda installed?` error (#48)

* Improves error messages when installing, and connecting to Databricks (#44 #45)


# pysparklyr 0.1.0

* Initial CRAN submission.
