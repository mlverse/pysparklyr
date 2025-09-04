# Linear Regression works with Spark Connection

    Code
      class(ml_linear_regression(sc, max_iter = 10))
    Output
      [1] "ml_linear_regression" "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

# Linear Regression works with `tbl_spark`

    Code
      model$features
    Output
       [1] "cyl"  "disp" "hp"   "drat" "wt"   "qsec" "vs"   "am"   "gear" "carb"

---

    Code
      model$label
    Output
      [1] "mpg"

---

    Code
      model %>% ml_predict(tbl_mtcars) %>% colnames()
    Output
       [1] "mpg"        "cyl"        "disp"       "hp"         "drat"      
       [6] "wt"         "qsec"       "vs"         "am"         "gear"      
      [11] "carb"       "prediction"

# Linear Regression works with Pipeline

    Code
      cap_out[c(1, 3:4, 6:18)]
    Output
       [1] "Pipeline (Estimator) with 1 stage"   "  Stages "                          
       [3] "  |--1 LinearRegression (Regressor)" "  |    (Parameters)"                
       [5] "  |    aggregationDepth: 2"          "  |    elasticNetParam: 0"          
       [7] "  |    epsilon: 1.35"                "  |    featuresCol: features"       
       [9] "  |    fitIntercept: TRUE"           "  |    labelCol: label"             
      [11] "  |    loss: squaredError"           "  |    maxBlockSizeInMB: 0"         
      [13] "  |    maxIter: 100"                 "  |    predictionCol: prediction"   
      [15] "  |    regParam: 0"                  "  |    solver: auto"                

# Logistic regression works

    Code
      class(ml_logistic_regression(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ml_logistic_regression(sc))
    Output
      [1] "ml_logistic_regression" "ml_connect_estimator"   "ml_estimator"          
      [4] "ml_pipeline_stage"     

---

    Code
      class(model)
    Output
      [1] "ml_connect_model"             "ml_model_logistic_regression"
      [3] "ml_model_classification"      "ml_model_prediction"         
      [5] "ml_model"                    

---

    Code
      table(fitted)
    Output
      fitted
       0  1 
      19 13 

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

