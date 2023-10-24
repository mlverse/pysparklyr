# Logistic Regression works with Spark Connection

    Code
      class(ml_logistic_regression(sc))
    Output
      [1] "ml_connect_estimator"        "ml_logistic_regression"     
      [3] "ml_probabilistic_classifier" "ml_classifier"              
      [5] "ml_predictor"                "ml_estimator"               
      [7] "ml_pipeline_stage"          

---

    Code
      model$features
    Output
       [1] "mpg"  "cyl"  "disp" "hp"   "drat" "wt"   "qsec" "vs"   "gear" "carb"

---

    Code
      model$label
    Output
      [1] "am"

---

    Code
      model %>% ml_predict(tbl_mtcars) %>% colnames()
    Output
       [1] "mpg"         "cyl"         "disp"        "hp"          "drat"       
       [6] "wt"          "qsec"        "vs"          "am"          "gear"       
      [11] "carb"        "prediction"  "probability"

