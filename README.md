
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pysparklyr

<!-- badges: start -->
<!-- badges: end -->

Integrates `sparklyr` with PySpark and Databricks. The main reson of
this package is because the new Spark and Databricks Connect connection
method does not work with standard `sparklyr` integration.

## Installation

Development of this package requires regular updates to `sparklyr`. The
most stable version of the integration will be available in a branch
called `demo`. Both packages have this branch. To install use:

``` r
library(remotes)

install_github("edgararuiz/pysparklyr", ref = "demo")
install_github("sparklyr/sparklyr", ref = "demo")
```

## Setup

Aside from PySpark, there are several Python libraries needed for the
integration to work. `pysparklyr` has a helper function
(`install_pyspark()`) that sets up a new Virtual Environment, and
installs the needed Python libraries:

``` r
library(sparklyr)
library(pysparklyr)

install_pyspark()
```

## Connecting

``` r
sc <- spark_connect(
  master = "https://rstudio-partner-posit-default.cloud.databricks.com",
  cluster_id = "0608-170338-jwkec0wi",
  method = "databricks_connect"
)
#> ✔ Using the 'r-sparklyr' virtual environment (/Users/edgar/.virtualenvs/r-sparklyr/bin/python)
```

<img src = 'man/readme/rstudio-connection.png'>

``` r
library(dplyr)
library(dbplyr)

trips <- tbl(sc, in_catalog("samples", "nyctaxi", "trips"))

trips
#> # Source: spark<`samples`.`nyctaxi`.`trips`> [?? x 6]
#>    tpep_pickup_datetime tpep_dropoff_datetime trip_distance fare_amount
#>    <dttm>               <dttm>                        <dbl>       <dbl>
#>  1 2016-02-14 10:52:13  2016-02-14 11:16:04            4.94        19  
#>  2 2016-02-04 12:44:19  2016-02-04 12:46:00            0.28         3.5
#>  3 2016-02-17 11:13:57  2016-02-17 11:17:55            0.7          5  
#>  4 2016-02-18 04:36:07  2016-02-18 04:41:45            0.8          6  
#>  5 2016-02-22 08:14:41  2016-02-22 08:31:52            4.51        17  
#>  6 2016-02-05 00:45:02  2016-02-05 00:50:26            1.8          7  
#>  7 2016-02-15 09:03:28  2016-02-15 09:18:45            2.58        12  
#>  8 2016-02-25 13:09:26  2016-02-25 13:24:50            1.4         11  
#>  9 2016-02-13 10:28:18  2016-02-13 10:36:36            1.21         7.5
#> 10 2016-02-13 18:03:48  2016-02-13 18:10:24            0.6          6  
#> # ℹ more rows
#> # ℹ 2 more variables: pickup_zip <int>, dropoff_zip <int>
```

``` r
trips %>% 
  group_by(pickup_zip) %>% 
  summarise(
    count = n(),
    avg_distance = mean(trip_distance, na.rm = TRUE)
  )
#> # Source: spark<?> [?? x 3]
#>    pickup_zip count avg_distance
#>         <int> <dbl>        <dbl>
#>  1      10032    15         4.49
#>  2      10013   273         2.98
#>  3      10022   519         2.00
#>  4      10162   414         2.19
#>  5      10018  1012         2.60
#>  6      11106    39         2.03
#>  7      10011  1129         2.29
#>  8      11103    16         2.75
#>  9      11237    15         3.31
#> 10      11422   429        15.5 
#> # ℹ more rows
```

``` r
spark_disconnect(sc)
```

## Progress

### Installation

- [x] Helper function to install Python and needed libraries

### Connectivity and Session

- [x] Initial connection routines
- [x] Spark Connect connectivity
- [ ] Initiate Spark Connect when creating new connection, similar to
  “local” (Maybe)

### RStudio Integration

- [x] Initial Connection contract works
- [x] Implement and integrate custom three layer (catalog, schema,
  table) structure for navigation
- [x] Implement column preview for `pyspark_connection`. Mainly because
  the current way does not allow for a three layer structure.
- [x] Implement “top 1000 row preview” for `pyspark_connection`. Mainly
  because the current way does not allow for a three layer structure.
- [x] `sparklyr` - Prevent showing the Spark and Log buttons if the
  connection has no target to offer
- [ ] Implement Spark and Log buttons for Spark Connect and DB Connect.
  **Blocked** - Until SparkSession is implemented in Spark 3.5

### DBI

- [x] Integration with DBI methods. This was done my modifying a couple
  of `sparklyr` routines. More testing is needed to confirm all works

### `dplyr`

- Implement needed methods:
  - [x] `tbl()`
  - [x] `collect()`
  - [x] `copy_to()` - Implemented for `sparklyr`’s `sdf_copy_to()` since
    it was already an exported method. This made it a drop in
    integration.

### Lower level integration

- [x] Implement the `invoke()` method for `pysparklyr_connection`
- [ ] Implement `invoke_new()` method for `pysparklyr_connection`.
  Initial implmentation is available, but more testing is needed.

### ML

- [ ] First successful run of an `ft_` function
- [ ] Run all `ft_` functions, and have all/most pass tests
  - [ ] Determine what to do with functions that will not run
- [ ] First successful run of an `ml_` function
- [ ] Run all `ft_` functions, and have all/most pass tests
  - [ ] Determine what to do with functions that will not run
- [ ] First successful run of an `sdf_` function
- [ ] Run all `sdf_` functions, and have all/most pass tests
  - [ ] Determine what to do with functions that will not run

### Data

- [ ] First successful run of an `spark_read_` / `spark_write_` function
- [ ] Run all `spark_read_` / `spark_write_` functions, and have
  all/most pass tests
  - [ ] Determine what to do with functions that will not run

### Stream

- [ ] Test streaming

### Arrow

- [ ] Test `arrow` integration
