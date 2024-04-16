# pysparklyr 0.1.4

### New

* Adds support for `spark_apply()` via the `rpy2` Python library
  * It will not automatically distribute packages, it will assume that the
  necessary packages are already installed in each node. This also means that
  the `packages` argument is not supported
  * As in its original implementation, schema inferring works, and as with the
  original implementation, it has a performance cost. Unlike the original, the 
  Databricks, and Spark, Connect version will return a 'columns' specification
  that you can use for the next time you run the call.
  
### Improvements

* At connection time, it enables Arrow by default. It does this by setting
these two configuration settings to true: 
  * `spark.sql.execution.arrow.pyspark.enabled`
  * `spark.sql.execution.arrow.pyspark.fallback.enabled`


# pysparklyr 0.1.3

### New

* Adds support for `sdf_schema()`

* Adds support for `spark_write_table()`

* Adds `deploy_databricks()` function. It will simplify publishing to Posit
Connect by automating much of the needed setup, and triggers the publication.

* Adds `requirements_write()` function. It will inventory the Python libraries
loaded in a given Python environment and create the 'requirements.txt'. This
is in an effort to make it easier to republish deployed content.

### Improvements

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

# pysparklyr 0.1.2

### Improvements

* When connecting,`spark_connect()`, it will automatically prompt the
user to install a Python Environment a viable one is not  not found. 
This way, the R user will not have to run `install_databricks()`/
`install_pyspark()` manually when using the package for the first time. (#69)

* Instead of simply warning that `RETICULATE_PYTHON` is set, it will now un-set
the variable. This allows `pysparklyr` to select the correct Python environment.
It will output a console message to the user when the variable is un-set. (#65).
Because of how Posit Connect manages `reticulate` Python environments, `pysparklyr`
will force the use of the Python environment under that particular published
content's `RETICULATE_PYTHON`.

* Adds enhanced RStudio Snippet for Databricks connections. It will automatically 
check the cluster's version by pooling the Databricks REST API with the cluster's
ID. This to check if there is a pre-installed Python environment that will
suport the cluster's version. All these generate notifications in the snippet's
UI. It also adds integration with Posit Workbench's new 'Databricks' pane. The
snippet looks for a specific environment variable that Posit Workbench temporarily
sets with the value of the cluster ID, and initializes the snippet with that
value. (#53)

* Adds `install_ml` argument to `install_databricks()` and `install_pyspark()`. 
The ML related Python libraries are very large, and take a long time to install.
In most cases, the user will not need these to interact with the cluster. The 
`install_ml` argument is a flag that will control if the ML libraries will
be installed. It defaults to `FALSE`. The first time the R user runs an ML 
related function, then `pysparklyr` will prompt them to install the needed
libraries at that time.(#63, #78)

* Adds support for Databricks OAuth by adding a handler to the Posit Connect 
integration. Internally, it centralizes the authentication processing into
one un-exported function. (#68)

* General improvements to all of console outputs

### Machine Learning

* Adds support for: 
  - `ft_standard_scaler()`
  - `ft_max_abs_scaler()`
  - `ml_logistic_regression()`
  - `ml_pipeline()`
  - `ml_save()`
  - `ml_predict()`
  - `ml_transform()`

* Adds `ml_prepare_dataset()` in lieu of a Vector Assembler transformer

### Fixes

* Fixes error in use_envname() - No environment name provided, and no 
environment was automatically identified (#71)

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
