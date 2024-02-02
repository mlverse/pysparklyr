# Adds the ML libraries when prompted

    Code
      x
    Output
      $packages
       [1] "pyspark==3.5.0"           "pandas!=2.1.0"           
       [3] "PyArrow"                  "grpcio"                  
       [5] "google-api-python-client" "grpcio_status"           
       [7] "rpy2"                     "torch"                   
       [9] "torcheval"                "scikit-learn"            
      
      $envname
                   unavailable 
      "r-sparklyr-pyspark-3.5" 
      
      $method
      [1] "auto"
      
      $pip
      [1] TRUE
      

# install_as_job() is able to run

    Code
      install_as_job(as_job = TRUE)
    Message
      v Running installation as a RStudio job 

# Installation runs even if no response from PyPi

    Code
      x
    Output
      $packages
      [1] "pyspark==3.5.*"           "pandas!=2.1.0"           
      [3] "PyArrow"                  "grpcio"                  
      [5] "google-api-python-client" "grpcio_status"           
      [7] "rpy2"                    
      
      $envname
                   unavailable 
      "r-sparklyr-pyspark-3.5" 
      
      $method
      [1] "auto"
      
      $pip
      [1] TRUE
      

# Install code is correctly created

    Code
      build_job_code(list(a = 1))
    Output
      [1] "pysparklyr:::install_environment(a = 1)"

# Databricks installation works

    Code
      out
    Output
      $main_library
      [1] "databricks-connect"
      
      $spark_method
      [1] "databricks_connect"
      
      $backend
      [1] "databricks"
      
      $ml_version
      [1] "14.1"
      
      $version
      [1] "14.1"
      
      $envname
      NULL
      
      $python_version
      NULL
      
      $new_env
      [1] TRUE
      
      $method
      [1] "auto"       "virtualenv" "conda"     
      
      $as_job
      [1] TRUE
      
      $install_ml
      [1] FALSE
      

---

    Code
      install_databricks(version = "13.1")
    Output
      $main_library
      [1] "databricks-connect"
      
      $spark_method
      [1] "databricks_connect"
      
      $backend
      [1] "databricks"
      
      $ml_version
      [1] "14.1"
      
      $version
      [1] "13.1"
      
      $envname
      NULL
      
      $python_version
      NULL
      
      $new_env
      [1] TRUE
      
      $method
      [1] "auto"       "virtualenv" "conda"     
      
      $as_job
      [1] TRUE
      
      $install_ml
      [1] FALSE
      

