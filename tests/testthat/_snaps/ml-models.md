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
      fitted
    Output
       [1] 1.56 1.81 1.85 1.94 1.95 1.95 2.21 2.52 2.70 2.82 2.84 2.95 3.02 3.20 3.21
      [16] 3.38 3.41 3.50 3.52 3.55 3.55 3.61 3.64 3.70 3.72 3.75 3.76 3.92 3.96 4.80
      [31] 5.26 5.41

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
      [1] 24 29 38 59

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

