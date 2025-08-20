# Linear Regression works with Spark Connection

    Code
      class(ml_linear_regression(sc, max_iter = 10))
    Output
      [1] "ml_connect_estimator"        "ml_linear_regression"       
      [3] "ml_probabilistic_classifier" "ml_classifier"              
      [5] "ml_predictor"                "ml_estimator"               
      [7] "ml_pipeline_stage"          

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

