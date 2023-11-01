# use_envname function works

    Code
      use_envname("newtest", messages = TRUE)
    Message <cliMessage>
      ! Using the Python environment defined in the'RETICULATE_PYTHON' environment variable(/Library/Frameworks/Python.framework/Versions/3.11/bin/python3)
    Output
      [1] "/Library/Frameworks/Python.framework/Versions/3.11/bin/python3"

---

    Code
      use_envname(version = "1.1", messages = TRUE, match_first = TRUE)
    Message <cliMessage>
      ! A Python environment with a matching version was not found
      * Will attempt connecting using 'r-sparklyr-pyspark-3.5'
      * To install the proper Python environment use: `pysparklyr::install_pyspark(version = "1.1")`
    Output
      [1] "r-sparklyr-pyspark-3.5"

