# Random Forest Classifier works

    Code
      class(ml_random_forest_classifier(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ml_random_forest_classifier(sc))
    Output
      [1] "ml_random_forest_classifier" "ml_connect_estimator"       
      [3] "ml_estimator"                "ml_pipeline_stage"          

---

    Code
      class(model)
    Output
      [1] "ml_connect_model"                  "ml_model_random_forest_classifier"
      [3] "ml_model_classification"           "ml_model_prediction"              
      [5] "ml_model"                         

---

    Code
      table(x$prediction)
    Output
      
       0  1  2 
      50 48 52 

# Random Forest Regressor works

    Code
      class(ml_random_forest_regressor(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ml_random_forest_regressor(sc))
    Output
      [1] "ml_random_forest_regressor" "ml_connect_estimator"      
      [3] "ml_estimator"               "ml_pipeline_stage"         

---

    Code
      class(model)
    Output
      [1] "ml_connect_model"                 "ml_model_random_forest_regressor"
      [3] "ml_model_regression"              "ml_model_prediction"             
      [5] "ml_model"                        

