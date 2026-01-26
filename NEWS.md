# pysparklyr 0.2.0

### Fixes

* Adds support for Pandas 3.0 conversion (#169)

* Properly converts Pandas columns to R (#165 - @romangehrn) 

* Switches to using the configuration file in Posit Workbench to obtain the
Databricks OAuth token. This guarantees that RMarkdown and Quarto documents
that attempt to access a Databricks cluster are successful (#166)

### Improvements

* Adds support for Databricks Viewer OAuth credentials. 

* Adds support for Snowflake's [Snowpark Connect](https://docs.snowflake.com/en/developer-guide/snowpark-connect/snowpark-connect-overview).
New method name is `snowpark_connect`.

* Adds support for new ML methodology implemented in Spark 4.0 (#153). Specific
ML functions now supported are:
  * New in Spark 4.0
    * `ml_generalized_linear_regression()`
    * `ml_isotonic_regression()`
    * `ml_gbt_classifier()`
    * `ml_gbt_regressor()`
    * `ml_aft_survival_regression()`
    * `ml_bisecting_kmeans()`
    * `ml_decision_tree_regressor()`
    * `ml_multiclass_classification_evaluator()`
    * `ml_regression_evaluator`
    * `ml_binary_classification_evaluator()`
    * `ml_clustering_evaluator()`
    * `ml_kmeans()`
    * `ml_decision_tree_classifier()`
    * `ml_cross_validator()`
    * `ft_word2vec()`
    * `ft_vector_slicer()`
    * `ft_vector_indexer()`
    * `ft_sql_transformer()`
    * `ft_robust_scaler()`
    * `ft_regex_tokenizer()`
    * `ft_quantile_discretizer()`
    * `ft_polynomial_expansion()`
    * `ft_pca()`
    * `ft_one_hot_encoder()`
    * `ft_ngram()`
    * `ft_minhash_lsh()`
    * `ft_min_max_scaler()`
    * `ft_index_to_string()`
    * `ft_imputer()`
    * `ft_idf()`
    * `ft_feature_hasher()`
    * `ft_elementwise_product()`
    * `ft_vector_assembler()`
    * `ft_dct()` / `ft_discrete_cosine_transform()`
    * `ft_bucketed_random_projection_lsh()`
    * `ft_count_vectorizer()`
    * `ml_linear_regression()`
    * `ml_random_forest_regressor()`
    * `ml_random_forest_classifier()`
    * `ft_string_indexer()`
    * `ft_tokenizer()`
    * `ft_stop_words_remover()`
    * `ft_hashing_tf()`
    * `ft_normalizer()`
    * `ft_binarizer()`
    * `ft_bucketizer()`
    * `ft_r_formula()`
  * Updated for Spark 4.0
    * `ml_logistic_regression()`
    * `ft_standard_scaler()`
    * `ft_max_abs_scaler()`
    * `ml_pipeline()`
    * `ml_save()`

* Tests switch over to using `uv` for setup 

# pysparklyr 0.1.9

### Improvements

* Databricks connections app:
  * Adds a dropdown to the Python Environment to make it more flexible
  * Check for the existence of a Virtual Environment folder inside the current 
    RStudio project, adds it to the dropdown choices and makes it the default

* Adds support for spark_write_delta() (#146)

### Fixes

* Gets token from Databricks SDK if one cannot be found. (#148)


### Internal improvements

* Switches base Python environment for tests to uv

# pysparklyr 0.1.8

### Fixes

* Avoids installing `rpy2` automatically for `uv`-based environments. It will
also install `rpy2` via `py_require()` when `spark_apply()` is called.

* Fixes issue with resetting the connection label (#144)

* Restores Databricks Host name sanitation 

# pysparklyr 0.1.7

### Improvements

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

### Fixes

* Databricks connections should now correctly use `databricks_host()`

# pysparklyr 0.1.6

### Improvements

* Adds IDE check for positron (#121)

* No longer install 'rpy2' by default. It will prompt user for installation
the first time `spark_apply()` is called (#125)

### Fixes

* Fixes error returned by `httr2` to sanitize the Databricks Host URL (#130)

* Fixes issues with catalog and schema names with dashes in the Connections
Pane. 

* Avoids failure when an unexpected error from Databricks is returned (#123)

# pysparklyr 0.1.5

### Improvements

* Adds support for `I()` in `tbl()`

* Ensures `arrow` is installed by adding it to Imports (#116)

* If the cluster version is higher than the available Python library, it will
either use, or offer to install the available Python library

### Fixes

* Fixes issues with having multiple line functions in `spark_apply()`

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
