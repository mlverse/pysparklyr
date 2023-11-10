# Functions work

    Code
      model
    Message <cliMessage>
      
      -- ML Connect model: 
    Output
      Logistic Regression
    Message <cliMessage>
      
      -- Parameters: 
    Output
      [x] batchSize:       32            [x] momentum:        0.9        
      [x] featuresCol:     features      [x] numTrainWorkers: 1          
      [x] fitIntercept:    TRUE          [x] predictionCol:   prediction 
      [x] labelCol:        label         [x] probabilityCol:  probability
      [x] learningRate:    0.001         [x] seed:            0          
      [x] maxIter:         10            [x] tol:             1e-06      

---

    Code
      colnames(transform_impl(model, tbl_mtcars, prep = TRUE))
    Output
       [1] "mpg"         "cyl"         "disp"        "hp"          "drat"       
       [6] "wt"          "qsec"        "vs"          "am"          "gear"       
      [11] "carb"        "label"       "features"    "prediction"  "probability"

---

    Code
      colnames(transform_impl(model, tbl_mtcars, prep = TRUE, remove = TRUE))
    Output
       [1] "mpg"         "cyl"         "disp"        "hp"          "drat"       
       [6] "wt"          "qsec"        "vs"          "am"          "gear"       
      [11] "carb"        "prediction"  "probability"

