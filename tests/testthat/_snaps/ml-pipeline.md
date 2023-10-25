# Pipeline fits and predicts

    Code
      class(fitted)
    Output
      [1] "ml_connect_pipeline_model" "ml_pipeline_model"        
      [3] "ml_transformer"            "ml_connect_transformer"   
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      fitted %>% ml_transform(prepd) %>% colnames()
    Output
       [1] "mpg"         "cyl"         "disp"        "hp"          "drat"       
       [6] "wt"          "qsec"        "vs"          "am"          "gear"       
      [11] "carb"        "prediction"  "probability"

