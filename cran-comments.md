## Package submission

In this version, there are three major additions:

- Machine learning is now supported. They are two feature transformers,
and one model. It includes fitting, prediction, and saving. ML Pipelines are 
also supported.

- Adds a new RStudio Connection snippet to support new Databricks connections.
It validates the cluster validity, and version, and provides the connection
code.

- Improves user experience by including the Python environment installation if
one is needed. Prior, the user would have to manually run the installation 
function before connecting. With this update, the user will be prompted to 
accept the installation. By default, it will not install ML related Python
libraries. The first time the user runs a function that needs such ML
libraries, then at that time they will be prompted to install.

## Test environments

- Ubuntu 22.04, R 4.3.2, Spark 3.5 (GH Actions)
- Ubuntu 22.04, R 4.3.2, Spark 3.4 (GH Actions)

- Local Mac OS M1 (aarch64-apple-darwin20), R 4.3.1, Spark 3.5 (Local)

## R CMD check environments

- Mac OS M1 (aarch64-apple-darwin20), R 4.3.1 (Local)

- Mac OS x86_64-apple-darwin20.0 (64-bit), R 4.3.2 (GH Actions)
- Windows x86_64-w64-mingw32 (64-bit), R 4.3.2 (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.3.2 (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.4.0 (dev) (GH Actions)
- Linux x86_64-pc-linux-gnu (64-bit), R 4.2.3 (old release) (GH Actions)


## R CMD check results

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

