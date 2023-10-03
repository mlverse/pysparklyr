## New package re-submission

Address feedback from CRAN. It adds the a \value section to the the Rd files 
that were missing them. 

### Original submission message

New package submission. It is an extension to the 'sparklyr' package that
enables integration with the new 'Spark Connect' via 'Python'. This package
uses the 'reticulate' package to interact with 'Python'.

As with 'sparklyr', an active Spark connection is needed in order to
effectively test this package. This is why the tests inside the "test" folder
do not run with checking the package. We have setup GitHub Actions to 
automatically setup multiple Spark environments, and to run the tests against
each of the Spark versions. This is the same approach 'sparklyr' has for
testing. This is also the reason why no examples are provided in exported 
functions. 

The README file is very short because all the information about how to use
this package is in this article: https://spark.rstudio.com/deployment/databricks-spark-connect.html.
That is also noted in the README.  

## Test environments

- Ubuntu 22.04, R 4.3.1, Spark 3.5 (GH Actions)
- Ubuntu 22.04, R 4.3.1, Spark 3.4 (GH Actions)

- Local Mac OS M1 (aarch64-apple-darwin20), R 4.3.1, Spark 3.4 (Local)
- Local Mac OS M1 (aarch64-apple-darwin20), R 4.3.1, Spark 3.5 (Local)

## R CMD check environments

- Mac OS M1 (aarch64-apple-darwin20), R 4.3.1 (Local)

- Mac OS x86_64-apple-darwin20.0 (64-bit), R 4.3.1 (GH Actions)
- Windows  x86_64-w64-mingw32 (64-bit), R 4.3.1 (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.3.1 (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.4.0 (dev) (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.2.3 (old release) (GH Actions)


## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.
