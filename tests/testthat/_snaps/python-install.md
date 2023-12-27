# Databricks installation works

    Code
      out
    Output
      $libs
      [1] "databricks-connect"
      
      $version
      [1] "14.1"
      
      $envname
      NULL
      
      $python_version
      [1] ">=3.9"
      
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
      $libs
      [1] "databricks-connect"
      
      $version
      [1] "13.1"
      
      $envname
      NULL
      
      $python_version
      [1] ">=3.9"
      
      $new_env
      [1] TRUE
      
      $method
      [1] "auto"       "virtualenv" "conda"     
      
      $as_job
      [1] TRUE
      
      $install_ml
      [1] FALSE
      

# Install as job works

    Code
      install_as_job(as_job = TRUE)
    Message
      v Running installation as a RStudio job 

# Install code is correctly created

    Code
      build_job_code(list(a = 1))
    Output
      [1] "pysparklyr:::install_environment(a = 1)"

