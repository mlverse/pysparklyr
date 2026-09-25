# Environment names per back-end

    Code
      out
    Output
      [[1]]
                   unavailable 
      "r-sparklyr-pyspark-3.5" 
      
      [[2]]
                   unavailable 
      "r-sparklyr-pyspark-3.5" 
      
      [[3]]
                        latest 
      "r-sparklyr-pyspark-4.2" 
      
      [[4]]
                     unavailable 
      "r-sparklyr-pyspark-4.2.0" 
      
      [[5]]
                       unavailable 
      "r-sparklyr-databricks-16.1" 
      
      [[6]]
                            latest 
      "r-sparklyr-databricks-17.3" 
      
      [[7]]
                        unavailable 
      "r-sparklyr-snowflake-latest" 
      
      [[8]]
                      unavailable 
      "r-sparklyr-snowflake-1.20" 
      

# Environment names when other environments exist

    Code
      use_envname(backend = "pyspark", main_library = "pyspark", backend_version = "3.5",
        messages = TRUE, match_first = TRUE, ignore_reticulate_python = TRUE)
    Message
      ! You do not have a Python environment that matches your Spark Connect cluster
        Run: `pysparklyr::install_pyspark(version = "3.5")` to install.
    Output
                         first 
      "r-sparklyr-pyspark-3.4" 
    Code
      use_envname(backend = "pyspark", main_library = "pyspark", backend_version = "4.2",
        messages = TRUE, match_first = TRUE, ignore_reticulate_python = TRUE)
    Message
      ! You do not have a Python environment that matches your Spark Connect cluster
        Run: `pysparklyr::install_pyspark(version = "4.2")` to install.
    Output
                         first 
      "r-sparklyr-pyspark-3.4" 
    Code
      use_envname(backend = "pyspark", main_library = "pyspark", backend_version = "3.4",
        messages = TRUE, match_first = TRUE, ignore_reticulate_python = TRUE)
    Output
                         exact 
      "r-sparklyr-pyspark-3.4" 

# Environment names when PyPI cannot be reached

    Code
      use_envname(backend = "pyspark", main_library = "pyspark", backend_version = "3.5",
        messages = FALSE, match_first = TRUE, ignore_reticulate_python = TRUE)
    Output
                         first 
      "r-sparklyr-pyspark-3.4" 

# Python requirements per back-end

    Code
      out
    Output
      [[1]]
      [[1]]$packages
      [1] "pyspark==3.5.0"  "py4j==0.10.9.7"  "numpy>=1.21"     "pandas>=1.4.4"  
      [5] "pyarrow>=11.0.0" "pip"            
      
      [[1]]$python_version
      [1] ">=3.10"
      
      
      [[2]]
      [[2]]$packages
      [1] "databricks.connect==16.1.0"       "databricks-sdk>=0.29.0"          
      [3] "googleapis-common-protos>=1.56.4" "grpcio>=1.59.3"                  
      [5] "pandas>=1.0.5"                    "pyarrow>=4.0.0"                  
      [7] "pip"                             
      
      [[2]]$python_version
      [1] "3.12"
      
      
      [[3]]
      [[3]]$packages
      [1] "databricks.connect==14.1.0"       "databricks-sdk>=0.29.0"          
      [3] "googleapis-common-protos>=1.56.4" "grpcio>=1.59.3"                  
      [5] "pandas>=1.0.5"                    "pyarrow>=4.0.0"                  
      [7] "pip"                             
      
      [[3]]$python_version
      [1] "3.10"
      
      
      [[4]]
      [[4]]$packages
      [1] "snowflake-snowpark-python==1.20.0"  "setuptools>=40.6.0"                
      [3] "snowflake-connector-python>=3.12.0" "pandas"                            
      [5] "pip"                               
      
      [[4]]$python_version
      [1] ">=3.10"
      
      

---

    Code
      python_requirements(backend = "pyspark", main_library = "pyspark",
        backend_version = "3.5", install_ml = TRUE, add_torch = TRUE)
    Output
      $packages
      [1] "pyspark==3.5.0"  "py4j==0.10.9.7"  "numpy>=1.21"     "pandas>=1.4.4"  
      [5] "pyarrow>=11.0.0" "torch"           "torcheval"       "scikit-learn"   
      [9] "pip"            
      
      $python_version
      [1] ">=3.10"
      

# Python requirements when PyPI cannot be reached

    Code
      python_requirements(backend = "pyspark", main_library = "pyspark",
        backend_version = "3.5", python_version = "3.10")
    Output
      $packages
      [1] "pyspark==3.5.*"           "pandas!=2.1.0"           
      [3] "PyArrow"                  "grpcio"                  
      [5] "google-api-python-client" "grpcio_status"           
      [7] "databricks-sdk"           "zstandard"               
      [9] "pip"                     
      
      $python_version
      [1] "3.10"
      

# Installed packages per back-end

    Code
      install(main_library = "pyspark", spark_method = "pyspark_connect", backend = "pyspark",
        ml_version = "3.5", backend_version = "3.5")
    Message
      v Automatically naming the environment:'r-sparklyr-pyspark-3.5'
    Output
      $packages
      [1] "pyspark==3.5.0"           "pandas!=2.1.0"           
      [3] "PyArrow"                  "grpcio"                  
      [5] "google-api-python-client" "grpcio_status"           
      [7] "databricks-sdk"           "zstandard"               
      
      $envname
                   unavailable 
      "r-sparklyr-pyspark-3.5" 
      
      $python_version
      [1] ">=3.10"
      
    Code
      install(main_library = "pyspark", spark_method = "pyspark_connect", backend = "pyspark",
        ml_version = "3.5", backend_version = NULL, install_ml = TRUE)
    Message
      v Automatically naming the environment:'r-sparklyr-pyspark-4.2'
    Output
      $packages
       [1] "pyspark==4.2.0"           "pandas!=2.1.0"           
       [3] "PyArrow"                  "grpcio"                  
       [5] "google-api-python-client" "grpcio_status"           
       [7] "databricks-sdk"           "zstandard"               
       [9] "torch"                    "torcheval"               
      [11] "scikit-learn"            
      
      $envname
                   unavailable 
      "r-sparklyr-pyspark-4.2" 
      
      $python_version
      [1] ">=3.10"
      
    Code
      install(main_library = "databricks-connect", spark_method = "databricks_connect",
        backend = "databricks", ml_version = "14.1", backend_version = "16.1")
    Message
      v Automatically naming the environment:'r-sparklyr-databricks-16.1'
    Output
      $packages
      [1] "databricks-connect==16.1.0" "pandas!=2.1.0"             
      [3] "PyArrow"                    "grpcio"                    
      [5] "google-api-python-client"   "grpcio_status"             
      [7] "databricks-sdk"             "zstandard"                 
      
      $envname
                       unavailable 
      "r-sparklyr-databricks-16.1" 
      
      $python_version
      [1] ">=3.10"
      

# Installed packages when PyPI cannot be reached

    Code
      x[c("packages", "envname", "python_version")]
    Output
      $packages
      [1] "databricks-connect==16.1.*" "pandas!=2.1.0"             
      [3] "PyArrow"                    "grpcio"                    
      [5] "google-api-python-client"   "grpcio_status"             
      [7] "databricks-sdk"             "zstandard"                 
      
      $envname
                       unavailable 
      "r-sparklyr-databricks-16.1" 
      
      $python_version
      [1] "3.12"
      

# Install job code per back-end

    Code
      install_pyspark(version = "3.5")
    Output
      Installing 'pyspark' version '3.5'
      pysparklyr:::install_environment(main_library = "pyspark", spark_method = "pyspark_connect", backend = "pyspark", ml_version = "3.5", backend_version = "3.5", main_library_version = "3.5", envname = , python_version = , new_env = TRUE, method = "auto", install_ml = FALSE)
    Message
      v Running installation as a RStudio job 
    Code
      install_databricks(version = "16.1")
    Output
      Installing 'databricks-connect' version '16.1'
      pysparklyr:::install_environment(main_library = "databricks-connect", spark_method = "databricks_connect", backend = "databricks", ml_version = "14.1", backend_version = "16.1", main_library_version = "16.1", envname = , python_version = , new_env = TRUE, method = "auto", install_ml = FALSE)
    Message
      v Running installation as a RStudio job 

