
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

# Setup

Aside from PySpark, there are several Python libraries needed for the
integration to work. `pysparklyr` has a helper function
(`install_pyspark()`) that sets up a new Virtual Environment, and
installs the needed Python libraries:

``` r
library(sparklyr)
library(pysparklyr)

install_pyspark()
```
