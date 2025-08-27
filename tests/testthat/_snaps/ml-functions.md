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
      [1] "ml_transformer"              "ml_connect_estimator"       
      [3] "ml_estimator"                "ml_pipeline_stage"          
      [5] "ml_random_forest_classifier"

---

    Code
      class(x)
    Output
      [1] "ml_connect_model"                  "ml_model_random_forest_classifier"
      [3] "ml_model_classification"           "ml_model_prediction"              
      [5] "ml_model"                         

