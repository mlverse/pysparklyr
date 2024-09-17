# Adds the ML libraries when prompted

    Code
      x
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

