# pysparklyr (Development)

### Improvements

* Suppresses targeted warning messages coming from Python. Specifically, 
deprecation warnings given to PySpark by Pandas for two variable types:
`is_datetime64tz_dtype`, and `is_categorical_dtype`

* Defaults Python environment creation and installation to run as an RStudio
job if the user is within the RStudio IDE. This feature can be overriden
using the new `as_job` argument inside `install_databricks()`, and 
`install_pyspark()` functions

* Adds a way to switch to using SQL to get catalog/schema/tables. It gets
turned on via 'SPARKLYR_RSTUDIO_CP_VIEW' being set to "uc_only" (#32)

### Diagnostics 

* `installed_components()` now displays the current version of `reticulate` in
the R session

* Adds handling of `RETICULATE_PYTHON` flag 

* Fixes `Error: Unable to find conda binary. Is Anaconda installed?` error (#48)

* Improves error messages when installing, and connecting to Databricks (#44 #45)



# pysparklyr 0.1.0

* Initial CRAN submission.
