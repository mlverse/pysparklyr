# Logistic Regression works with Spark Connection

    Code
      class(ml_logistic_regression(sc))
    Output
      [1] "ml_connect_estimator"        "ml_logistic_regression"     
      [3] "ml_probabilistic_classifier" "ml_classifier"              
      [5] "ml_predictor"                "ml_estimator"               
      [7] "ml_pipeline_stage"          

# Logistic Regression works with `tbl_spark`

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

# Logistic Regression works with Pipeline

    Code
      cap_out[c(1, 3:4, 6:18)]
    Output
       [1] "Pipeline (Estimator) with 1 stage"    
       [2] "  Stages "                            
       [3] "  |--1 LogisticRegression (Estimator)"
       [4] "  |    (Parameters)"                  
       [5] "  |    batchSize: 32"                 
       [6] "  |    featuresCol: features"         
       [7] "  |    fitIntercept: TRUE"            
       [8] "  |    labelCol: label"               
       [9] "  |    learningRate: 0.001"           
      [10] "  |    maxIter: 100"                  
      [11] "  |    momentum: 0.9"                 
      [12] "  |    numTrainWorkers: 1"            
      [13] "  |    predictionCol: prediction"     
      [14] "  |    probabilityCol: probability"   
      [15] "  |    seed: 0"                       
      [16] "  |    tol: 1e-06"                    

# Print method works

    Code
      ml_logistic_regression(sc)
    Message <rlang_message>
      <LogisticRegression>

