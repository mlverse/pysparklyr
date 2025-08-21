# Logistic Regression works with Spark Connection

    Code
      class(ml_logistic_regression(sc, max_iter = 10))
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
       [1] "mpg"           "cyl"           "disp"          "hp"           
       [5] "drat"          "wt"            "qsec"          "vs"           
       [9] "am"            "gear"          "carb"          "rawPrediction"
      [13] "probability"   "prediction"   

# Logistic Regression works with Pipeline

    Code
      cap_out[c(1, 3:4, 6:18)]
    Output
       [1] "Pipeline (Estimator) with 1 stage"                  
       [2] "  Stages "                                          
       [3] "  |--1 LogisticRegression (ProbabilisticClassifier)"
       [4] "  |    (Parameters)"                                
       [5] "  |    aggregationDepth: 2"                         
       [6] "  |    elasticNetParam: 0"                          
       [7] "  |    family: auto"                                
       [8] "  |    featuresCol: features"                       
       [9] "  |    fitIntercept: TRUE"                          
      [10] "  |    labelCol: label"                             
      [11] "  |    maxBlockSizeInMB: 0"                         
      [12] "  |    maxIter: 100"                                
      [13] "  |    predictionCol: prediction"                   
      [14] "  |    probabilityCol: probability"                 
      [15] "  |    rawPredictionCol: rawPrediction"             
      [16] "  |    regParam: 0"                                 

