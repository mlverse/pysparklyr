
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pysparklyr

<!-- badges: start -->

[![R-CMD-check](https://github.com/mlverse/pysparklyr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mlverse/pysparklyr/actions/workflows/R-CMD-check.yaml)
[![Spark-Connect](https://github.com/mlverse/pysparklyr/actions/workflows/spark-tests.yaml/badge.svg)](https://github.com/mlverse/pysparklyr/actions/workflows/spark-tests.yaml)
[![codecov](https://codecov.io/gh/mlverse/pysparklyr/graph/badge.svg?token=O1N9qPabpF)](https://app.codecov.io/gh/mlverse/pysparklyr)
[![CRAN
status](https://www.r-pkg.org/badges/version/pysparklyr)](https://CRAN.R-project.org/package=pysparklyr)
<!-- badges: end -->

Integrates `sparklyr` with PySpark and Databricks. The main reason of
this package is because the new Spark and Databricks Connect connection
method does not work with standard `sparklyr` integration.

## Installing

To install the version in CRAN use:

``` r
install.packages("pysparklyr")
```

To get the development version from GitHub use:

``` r
remotes::install_github("mlverse/pysparklyr")
```

## Using

To learn how to use, please visit the Spark / Databricks Connect
article, available in the official `sparklyr` website: [Spark Connect,
and Databricks Connect
v2](https://spark.posit.co/deployment/databricks-connect.html)
