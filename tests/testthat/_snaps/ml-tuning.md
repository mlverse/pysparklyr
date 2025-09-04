# Cross validator works

    Code
      class(cv)
    Output
      [1] "ml_connect_cross_validator" "ml_cross_validator"        
      [3] "ml_connect_estimator"       "ml_estimator"              
      [5] "ml_pipeline_stage"         

---

    Code
      class(tuning_model)
    Output
      [1] "ml_connect_cross_validator_model" "ml_cross_validator_model"        

---

    Code
      metrics
    Output
      # A tibble: 3 x 2
        areaUnderROC regParam
               <dbl>    <dbl>
      1        1          0  
      2        0.984      0.5
      3        0.984      1  

