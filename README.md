
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

install_github("sparklyr/sparklyr")
install_github("edgararuiz/pysparklyr")
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

## Connecting to Databricks (ML 13+)

For convenience, and safety, you can save your authentication token
(PAT), and your company’s Databrick’s URL in a environment variable. The
two variables are:

- `DATABRICKS_TOKEN`
- `DATABRICKS_HOST`

This will prevent your token to be shown in plain text in your code. You
can set the environment variables at the beginning of your R session
using `Sys.setenv()`. Preferably, the two variables can be set for all R
sessions by saving them to the `.Renviron` file. The `usethis` package
has a handy function that opens the file so you can edit it:
`usethis::edit_r_environ()`. Just add the two entries to your
`.Renviron` file.

After that, use `spark_connect()` to open the connection to Databricks.
You will need to only pass the `cluster_id` of your cluster, and tell
`sparklyr` that you are connecting to a cluster version ML 13+ by using
`method = "databricks_connect"`

``` r
sc <- spark_connect(
  cluster_id = "0608-170338-jwkec0wi",
  method = "databricks_connect"
)
#> ✔ Using the 'r-sparklyr' virtual environment (/Users/edgar/.virtualenvs/r-sparklyr/bin/python)
```

## Using with Databricks 13+

Through `pysparklyr`, `sparklyr` is able to display the navigation to
the full data catalog accessible to your user in Databricks. That will
be displayed in the RStudio’s Connections Pane, as shown below.

<img src="man/readme/rstudio-connection.png"/>

You can use `dbplyr`’s `in_catalog()` function to access the different
tables inside your data catalog. After pointing `tbl()` to a specific
table, you can use `dplyr`.

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
