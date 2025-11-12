# Tests deploy_databricks() happy path cases

    Code
      deploy_databricks()
    Output
      $appDir
      NULL
      
      $lint
      [1] FALSE
      
      $python
      NULL
      
      $version
      [1] "17.3"
      
      $backend
      [1] "databricks"
      
      $main_library
      [1] "databricks-connect"
      
      $envVars
      [1] "DATABRICKS_HOST"  "DATABRICKS_TOKEN"
      
      $env_var_message
                                    i                                 
           "{.header Host URL:} test" "{.header Token:} '<REDACTED>'" 
      
      $account
      NULL
      
      $server
      NULL
      
      $confirm
      [1] FALSE
      

---

    Code
      deploy_databricks(host = "another", token = "token")
    Output
      $appDir
      NULL
      
      $lint
      [1] FALSE
      
      $python
      NULL
      
      $version
      [1] "17.3"
      
      $backend
      [1] "databricks"
      
      $main_library
      [1] "databricks-connect"
      
      $envVars
      [1] "CONNECT_DATABRICKS_HOST"  "CONNECT_DATABRICKS_TOKEN"
      
      $env_var_message
                                    i                                 
        "{.header Host URL:} another" "{.header Token:} '<REDACTED>'" 
      
      $account
      NULL
      
      $server
      NULL
      
      $confirm
      [1] FALSE
      

# Tests deploy_databricks() error cases

    Code
      deploy_databricks()
    Condition
      Error:
      ! Cluster setup errors:
        - No host URL was provided or found. Please either set the 'DATABRICKS_HOST' environment variable, or pass the `host` argument.
        - No token was provided or found. Please either set the 'DATABRICKS_TOKEN' environment variable, or pass the `token` argument.

---

    Code
      deploy_databricks(host = "another")
    Condition
      Error:
      ! Cluster setup errors:
        - No token was provided or found. Please either set the 'DATABRICKS_TOKEN' environment variable, or pass the `token` argument.

