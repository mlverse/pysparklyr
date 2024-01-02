# ml_formula() works

    Code
      ml_formula(am ~ mpg, mtcars)
    Output
      $label
      [1] "am"
      
      $features
      [1] "mpg"
      

# ml_installed() works on simulated interactive session

    Code
      ml_installed(envname = test_env)
    Message
      ! Required Python libraries to run ML functions are missing
        Could not find: torch, torcheval, and scikit-learn
        Do you wish to install? (This will be a one time operation)

