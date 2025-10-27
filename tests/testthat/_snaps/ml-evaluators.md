# Binary evaluation works

    Code
      class(ml_binary_classification_evaluator(sc))
    Output
      [1] "ml_connect_estimator" "ml_estimator"         "ml_pipeline_stage"   

---

    Code
      ml_binary_classification_evaluator(preds, label_col = "am")
    Output
      [1] 1

# Regression evaluation works

    Code
      class(ml_regression_evaluator(sc))
    Output
      [1] "ml_connect_estimator" "ml_estimator"         "ml_pipeline_stage"   

---

    Code
      ml_regression_evaluator(preds, label_col = "wt", metric_name = "r2")
    Output
      [1] 0.9442661

# Multiclass evaluation works

    Code
      class(ml_multiclass_classification_evaluator(sc))
    Output
      [1] "ml_connect_estimator" "ml_estimator"         "ml_pipeline_stage"   

---

    Code
      ml_multiclass_classification_evaluator(preds, label_col = "species_idx")
    Output
      [1] 0.9933327

# Clustering evaluation works

    Code
      class(ml_clustering_evaluator(sc))
    Output
      [1] "ml_connect_estimator" "ml_estimator"         "ml_pipeline_stage"   

---

    Code
      preds %>% mutate(prediction = as.numeric(prediction)) %>% compute() %>%
        ml_regression_evaluator(label_col = "species_idx")
    Output
      [1] 1.407125

