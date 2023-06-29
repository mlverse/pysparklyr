---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->





# pysparklyr

<!-- badges: start -->

<!-- badges: end -->

Integrates `sparklyr` with PySpark and Databricks. The main reson of this package is because the new Spark and Databricks Connect connection method does not work with standard `sparklyr` integration.

## Installation

Development of this package requires regular updates to `sparklyr`. The most stable version of the integration will be available in a branch called `demo`. Both packages have this branch. To install use:

``` r
library(remotes)

install_github("edgararuiz/pysparklyr", ref = "demo")
install_github("sparklyr/sparklyr", ref = "demo")
```

## Setup

Aside from PySpark, there are several Python libraries needed for the integration to work. `pysparklyr` has a helper function (`install_pyspark()`) that sets up a new Virtual Environment, and installs the needed Python libraries:

``` r
library(sparklyr)
library(pysparklyr)

install_pyspark()
```

## Connecting


```r
sc <- spark_connect(
  master = "https://rstudio-partner-posit-default.cloud.databricks.com",
  cluster_id = "0608-170338-jwkec0wi",
  method = "databricks_connect"
)
```

<img src="man/readme/rstudio-connection.png"/>


```r
library(dplyr)
library(dbplyr)

trips <- tbl(sc, in_catalog("samples", "nyctaxi", "trips"))

trips
```


```r
trips %>% 
  group_by(pickup_zip) %>% 
  summarise(
    count = n(),
    avg_distance = mean(trip_distance, na.rm = TRUE)
  )
```


```r
spark_disconnect(sc)
```

## Progress

### Installation

-   [x] Helper function to install Python and needed libraries

### Connectivity and Session

-   [x] Initial connection routines
-   [x] Spark Connect connectivity
-   [ ] Initiate Spark Connect when creating new connection, similar to "local" (Maybe)
-   [ ] Fail when user changes from one connection to another in the same R/Python session

### RStudio Integration

-   [x] Initial Connection contract works
-   [x] Implement and integrate custom three layer (catalog, schema, table) structure for navigation
-   [x] Implement column preview for `pyspark_connection`. Mainly because the current way does not allow for a three layer structure.
-   [x] Implement "top 1000 row preview" for `pyspark_connection`. Mainly because the current way does not allow for a three layer structure.
-   [x] `sparklyr` - Prevent showing the Spark and Log buttons if the connection has no target to offer
-   [ ] Implement Spark and Log buttons for Spark Connect and DB Connect. **Blocked** - Until SparkSession is implemented in Spark 3.5
-   [ ] Find a way to get the Connection pane to be async to the IDE

### DBI

-   [x] Integration with DBI methods. This was done my modifying a couple of `sparklyr` routines. More testing is needed to confirm all works

### `dplyr`

-   Implement needed methods:
    -   [x] `tbl()`
    -   [x] `collect()`
    -   [x] `copy_to()` - Implemented for `sparklyr`'s `sdf_copy_to()` since it was already an exported method. This made it a drop in integration.

### Lower level integration

-   [x] Implement the `invoke()` method for `pysparklyr_connection`
-   [ ] Implement `invoke_new()` method for `pysparklyr_connection`. Initial implementation is available, but more testing is needed.

### Auth

-   [ ] Implement Databricks Oauth
-   [ ] Implement Azure auth
-   [x] Implement PATH based auth

### ML

**Blocked: MLlib not supported in Spark Connect 3.4**

-   [ ] First successful run of an `ft_` functions
-   [ ] Run all `ft_` functions, and have all/most pass tests
    -   [ ] Determine what to do with functions that will not run
-   [ ] First successful run of an `ml_` functions
-   [ ] Run all `ft_` functions, and have all/most pass tests
    -   [ ] Determine what to do with functions that will not run

### SDF

-   [ ] First successful run of an `sdf_` functions
-   [ ] Run all `sdf_` functions, and have all/most pass tests
    -   [ ] Determine what to do with functions that will not run

### Data

-   [ ] First successful run of an `spark_read_` / `spark_write_` function
-   [ ] Run all `spark_read_` / `spark_write_` functions, and have all/most pass tests
    -   [ ] Determine what to do with functions that will not run

### Stream

-   [ ] Test streaming

### Arrow

-   [ ] Test `arrow` integration

### Testing

-   [ ] Unit testing
-   [ ] Integration testing
    -   [ ] Add exported method to skip tests based on connection
    -   [ ] Add skip commands to specific tests
-   [ ] Environments
    -   [ ] Initial run against Spark Connect
    -   [ ] Initial run against Databricks Connect
-   [ ] CI
    -   [ ] Add Spark Connect to current GH Spark Tests action
    -   [ ] GH action that creates a Databricks cluster and runs tests
    -   [ ] GH action that creates a Azure cluster and runs tests