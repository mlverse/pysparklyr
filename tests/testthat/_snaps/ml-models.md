# Linear regression works

    Code
      class(ml_linear_regression(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ml_linear_regression(sc))
    Output
      [1] "ml_linear_regression" "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(model)
    Output
      [1] "ml_connect_model"           "ml_model_linear_regression"
      [3] "ml_model_regression"        "ml_model_prediction"       
      [5] "ml_model"                  

---

    Code
      model
    Message
      
      -- MLib model: LinearRegressionModel --
      
      -- Coefficients: 
    Output
      [x] Intercept:   -0.231   [x] qsec:         0.2  
      [x] mpg:         -0.042   [x] vs:          -0.066
      [x] cyl:         -0.057   [x] am:           0.018
      [x] disp:         0.007   [x] gear:        -0.094
      [x] hp:          -0.003   [x] carb:         0.249
      [x] drat:        -0.09    
    Message
      
      -- Summary: 
    Output
      [x] coefficientStandardErrors:  0.021, 0.11, 0.001, 0.002, ...
      [x] devianceResiduals:          -0.348, 0.548                 
      [x] explainedVariance:          0.876                         
      [x] featuresCol:                features                      
      [x] labelCol:                   label                         
      [x] meanAbsoluteError:          0.185                         
      [x] meanSquaredError:           0.052                         
      [x] objectiveHistory:           0                             
      [x] pValues:                    0.063, 0.608, 0, 0.166, 0.6...
      [x] predictionCol:              prediction                    
      [x] r2:                         0.944                         
      [x] r2adj:                      0.918                         
      [x] rootMeanSquaredError:       0.227                         
      [x] tValues:                    -1.961, -0.521, 5.382, -1.4...

---

    Code
      table(fitted)
    Output
      fitted
      1.55900135411341 1.81067617246545 1.84756092218193 1.93861174657084 
                     1                1                1                1 
      1.94832530351745 1.94886255642784  2.2053314288641 2.52216054899614 
                     1                1                1                1 
      2.69540024678001 2.81892062711135 2.83745176991162 2.94919486694395 
                     1                1                1                1 
      3.01952852412384 3.20180775134582 3.20559666785169 3.37986510841766 
                     1                1                1                1 
      3.40705494638848 3.49811137556416 3.52456457067068 3.55135115238746 
                     1                1                1                1 
      3.55375986616591  3.6109221660483 3.64134326346231 3.70283265417869 
                     1                1                1                1 
      3.72107527942338 3.75130603504419 3.75874266561439 3.91657343494422 
                     1                1                1                1 
      3.96169497242361 4.79663776498836 5.25849019580687 5.40924406126582 
                     1                1                1                1 

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
      model
    Message
      
      -- MLib model: LogisticRegressionModel --
      
      -- Coefficients: 
    Output
      [x] Intercept:    111.69   [x] wt:          -14.256
      [x] mpg:          0.032    [x] qsec:        -9.07  
      [x] cyl:         -5.49     [x] vs:          -15.41 
      [x] disp:        -0.065    [x] gear:         22.211
      [x] hp:           0.099    [x] carb:        -4.855 
      [x] drat:         16.286   
    Message
      
      -- Summary: 
    Output
      [x] accuracy:                   1                             
      [x] areaUnderROC:               1                             
      [x] falsePositiveRateByLabel:   0, 0                          
      [x] featuresCol:                features                      
      [x] labelCol:                   label                         
      [x] labels:                     0, 1                          
      [x] objectiveHistory:           0.675, 0.314, 0.201, 0.13, ...
      [x] precisionByLabel:           1, 1                          
      [x] predictionCol:              prediction                    
      [x] probabilityCol:             probability                   
      [x] recallByLabel:              1, 1                          
      [x] scoreCol:                   probability                   
      [x] truePositiveRateByLabel:    1, 1                          
      [x] weightCol:                  weightCol                     
      [x] weightedFalsePositiveRate:  0                             
      [x] weightedPrecision:          1                             
      [x] weightedRecall:             1                             
      [x] weightedTruePositiveRate:   1                             

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
      model
    Message
      
      -- MLib model: RandomForestClassificationModel --
      
      -- Summary: 
    Output
      [x] accuracy:                   0.987      
      [x] falsePositiveRateByLabel:   0, 0, 0.02 
      [x] labelCol:                   label      
      [x] labels:                     0, 1, 2    
      [x] objectiveHistory:           0          
      [x] precisionByLabel:           1, 1, 0.962
      [x] predictionCol:              prediction 
      [x] recallByLabel:              1, 0.96, 1 
      [x] truePositiveRateByLabel:    1, 0.96, 1 
      [x] weightCol:                  weightCol  
      [x] weightedFalsePositiveRate:  0.007      
      [x] weightedPrecision:          0.987      
      [x] weightedRecall:             0.987      
      [x] weightedTruePositiveRate:   0.987      

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
      model
    Message
      
      -- MLib model: RandomForestRegressionModel --
      
    Output
      [x] bootstrap:                TRUE         [x] maxDepth:                 5         
      [x] cacheNodeIds:             FALSE        [x] maxMemoryInMB:            256       
      [x] checkpointInterval:       10           [x] minInfoGain:              0         
      [x] featureSubsetStrategy:    auto         [x] minInstancesPerNode:      1         
      [x] featuresCol:              features     [x] minWeightFractionPerNode: 0         
      [x] impurity:                 variance     [x] numTrees:                 20        
      [x] labelCol:                 label        [x] predictionCol:            prediction
      [x] leafCol:                               [x] seed:                     100       
      [x] maxBins:                  32           [x] subsamplingRate:          1         

---

    Code
      class(model)
    Output
      [1] "ml_connect_model"                 "ml_model_random_forest_regressor"
      [3] "ml_model_regression"              "ml_model_prediction"             
      [5] "ml_model"                        

# Decision Tree Classifier works

    Code
      class(ml_decision_tree_classifier(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ml_decision_tree_classifier(sc))
    Output
      [1] "ml_decision_tree_classifier" "ml_connect_estimator"       
      [3] "ml_estimator"                "ml_pipeline_stage"          

---

    Code
      model
    Message
      
      -- MLib model: DecisionTreeClassificationModel --
      
    Output
      [x] cacheNodeIds:             FALSE           [x] maxMemoryInMB:            256          
      [x] checkpointInterval:       10              [x] minInfoGain:              0            
      [x] featuresCol:              features        [x] minInstancesPerNode:      1            
      [x] impurity:                 gini            [x] minWeightFractionPerNode: 0            
      [x] labelCol:                 label           [x] predictionCol:            prediction   
      [x] leafCol:                                  [x] probabilityCol:           probability  
      [x] maxBins:                  32              [x] rawPredictionCol:         rawPrediction
      [x] maxDepth:                 5               [x] seed:                     100          

---

    Code
      class(model)
    Output
      [1] "ml_connect_model"                  "ml_model_decision_tree_classifier"
      [3] "ml_model_classification"           "ml_model_prediction"              
      [5] "ml_model"                         

---

    Code
      table(x$prediction)
    Output
      
       0  1  2 
      50 49 51 

# Decision Tree Regressor works

    Code
      class(ml_decision_tree_regressor(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ml_decision_tree_regressor(sc))
    Output
      [1] "ml_decision_tree_regressor" "ml_connect_estimator"      
      [3] "ml_estimator"               "ml_pipeline_stage"         

---

    Code
      model
    Message
      
      -- MLib model: DecisionTreeRegressionModel --
      
    Output
      [x] cacheNodeIds:             FALSE        [x] maxDepth:                 5         
      [x] checkpointInterval:       10           [x] maxMemoryInMB:            256       
      [x] featuresCol:              features     [x] minInfoGain:              0         
      [x] impurity:                 variance     [x] minInstancesPerNode:      1         
      [x] labelCol:                 label        [x] minWeightFractionPerNode: 0         
      [x] leafCol:                               [x] predictionCol:            prediction
      [x] maxBins:                  32           [x] seed:                     100       

---

    Code
      class(model)
    Output
      [1] "ml_connect_model"                 "ml_model_decision_tree_regressor"
      [3] "ml_model_regression"              "ml_model_prediction"             
      [5] "ml_model"                        

# Kmeans works

    Code
      class(ml_kmeans(sc))
    Output
      [1] "ml_kmeans"            "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ml_kmeans(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      preds
    Output
      .
       0  1 
      53 97 

# Bisecting Kmeans works

    Code
      class(ml_bisecting_kmeans(sc))
    Output
      [1] "ml_bisecting_kmeans"  "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ml_bisecting_kmeans(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      preds
    Output
      .
       0  1  2  3 
      24 29 59 38 

# AFT Survival works

    Code
      class(ml_aft_survival_regression(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ml_aft_survival_regression(sc))
    Output
      [1] "ml_aft_survival_regressor" "ml_connect_estimator"     
      [3] "ml_estimator"              "ml_pipeline_stage"        

---

    Code
      model
    Message
      
      -- MLib model: AFTSurvivalRegressionModel --
      
      -- Coefficients: 
    Output
      [x] Intercept:    10.632   [x] age:         -0.065 
      [x] ecog_ps:     -0.067    [x] resid_ds:    -0.521 
      [x] rx:           0.521    
      [x] aggregationDepth:      2                      [x] maxBlockSizeInMB:      0                   
      [x] censorCol:             fustat                 [x] maxIter:               100                 
      [x] featuresCol:           features               [x] predictionCol:         prediction          
      [x] fitIntercept:          TRUE                   [x] quantileProbabilities: c(0.01, 0.05, 0.1...
      [x] labelCol:              label                  [x] tol:                   1e-06               

---

    Code
      class(model)
    Output
      [1] "ml_connect_model"                "ml_model_aft_survival_regressor"
      [3] "ml_model_regression"             "ml_model_prediction"            
      [5] "ml_model"                       

# GBT classifiers works

    Code
      class(ml_gbt_classifier(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ml_gbt_classifier(sc))
    Output
      [1] "ml_gbt_classifier"    "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(model)
    Output
      [1] "ml_connect_model"        "ml_model_gbt_classifier"
      [3] "ml_model_classification" "ml_model_prediction"    
      [5] "ml_model"               

---

    Code
      table(x)
    Output
      x
       0  1 
      19 13 

# GBT Regressor works

    Code
      class(ml_gbt_regressor(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ml_gbt_regressor(sc))
    Output
      [1] "ml_gbt_regressor"     "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      model
    Message
      
      -- MLib model: GBTRegressionModel --
      
    Output
      [x] cacheNodeIds:             FALSE        [x] maxIter:                  20        
      [x] checkpointInterval:       10           [x] maxMemoryInMB:            256       
      [x] featureSubsetStrategy:    auto         [x] minInfoGain:              0         
      [x] featuresCol:              features     [x] minInstancesPerNode:      1         
      [x] impurity:                 variance     [x] minWeightFractionPerNode: 0         
      [x] labelCol:                 label        [x] predictionCol:            prediction
      [x] leafCol:                               [x] seed:                     100       
      [x] lossType:                 squared      [x] stepSize:                 0.1       
      [x] maxBins:                  32           [x] subsamplingRate:          1         
      [x] maxDepth:                 5            [x] validationTol:            0.01      

---

    Code
      class(model)
    Output
      [1] "ml_connect_model"       "ml_model_gbt_regressor" "ml_model_regression"   
      [4] "ml_model_prediction"    "ml_model"              

# Isotonic regression works

    Code
      class(ml_isotonic_regression(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ml_isotonic_regression(sc))
    Output
      [1] "ml_isotonic_regressor" "ml_connect_estimator"  "ml_estimator"         
      [4] "ml_pipeline_stage"    

---

    Code
      model
    Message
      
      -- MLib model: IsotonicRegressionModel --
      
    Output
      [x] featureIndex:  0            [x] labelCol:      label     
      [x] featuresCol:   features     [x] predictionCol: prediction
      [x] isotonic:      TRUE         

---

    Code
      class(model)
    Output
      [1] "ml_connect_model"            "ml_model_isotonic_regressor"
      [3] "ml_model_regression"         "ml_model_prediction"        
      [5] "ml_model"                   

# Generalized linear regression works

    Code
      class(ml_generalized_linear_regression(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ml_generalized_linear_regression(sc))
    Output
      [1] "ml_generalized_linear_regressor" "ml_connect_estimator"           
      [3] "ml_estimator"                    "ml_pipeline_stage"              

---

    Code
      class(model)
    Output
      [1] "ml_connect_model"                     
      [2] "ml_model_generalized_linear_regressor"
      [3] "ml_model_regression"                  
      [4] "ml_model_prediction"                  
      [5] "ml_model"                             

