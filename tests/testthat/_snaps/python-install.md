# Adds the ML libraries when prompted

    Code
      install_environment(main_library = "pyspark", spark_method = "pyspark_connect",
        backend = "pyspark", version = "3.5", ml_version = "3.5", new_env = FALSE,
        python = Sys.which("python"), install_ml = TRUE)
    Message
      Retrieving version from PyPi.org
      v Using: 'pyspark' version 3.5.0, requires Python >=3.8 [5ms]
      
      v Automatically naming the environment:'r-sparklyr-pyspark-3.5'
    Output
      $packages
      [1] "pyspark==3.5.0"           "pandas!=2.1.0"           
      [3] "PyArrow"                  "grpcio"                  
      [5] "google-api-python-client" "grpcio_status"           
      [7] "torch"                    "torcheval"               
      [9] "scikit-learn"            
      
      $envname
                   unavailable 
      "r-sparklyr-pyspark-3.5" 
      
      $method
      [1] "auto"
      
      $python_version
                       python 
      "/usr/local/bin/python" 
      
      $pip
      [1] TRUE
      

# install_as_job() is able to run

    Code
      install_as_job(as_job = TRUE)
    Message
      v Running installation as a RStudio job 

# Installation runs even if no response from PyPi

    Code
      install_environment(main_library = "pyspark", spark_method = "pyspark_connect",
        backend = "pyspark", version = "3.5", ml_version = "3.5", new_env = FALSE,
        python = Sys.which("python"))
    Message
      v Automatically naming the environment:'r-sparklyr-pyspark-3.5'
    Output
      $packages
      [1] "pyspark==3.5.*"           "pandas!=2.1.0"           
      [3] "PyArrow"                  "grpcio"                  
      [5] "google-api-python-client" "grpcio_status"           
      
      $envname
                   unavailable 
      "r-sparklyr-pyspark-3.5" 
      
      $method
      [1] "auto"
      
      $python_version
                       python 
      "/usr/local/bin/python" 
      
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
      

