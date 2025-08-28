# Binarizer works

    Code
      class(ft_binarizer(sc, "a", "b"))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_binarizer(ml_pipeline(sc), "a", "b"))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

# Bucket Random Projection LSH works

    Code
      class(ft_bucketed_random_projection_lsh(sc, "a", "b"))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_bucketed_random_projection_lsh(ml_pipeline(sc), "a", "b"))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

# Bucketizer works

    Code
      class(ft_bucketizer(sc, "a", "b", c(1, 2, 3)))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_bucketizer(ml_pipeline(sc), "a", "b", c(1, 2, 3)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

# Count vectorizer works

    Code
      class(ft_count_vectorizer(sc, "a", "b"))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_count_vectorizer(ml_pipeline(sc), "a", "b"))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

---

    Code
      dplyr::pull(x)
    Output
      [[1]]
      SparseVector(13, {0: 1.0, 1: 1.0, 2: 1.0, 3: 1.0, 4: 1.0, 5: 1.0, 6: 1.0, 7: 1.0, 8: 1.0, 9: 1.0, 10: 1.0, 11: 1.0, 12: 1.0})
      

# R Formula works

    Code
      class(ft_r_formula(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ft_r_formula(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      ft_r_formula(tbl_mtcars, mpg ~ ., features_col = "test") %>% colnames()
    Output
       [1] "mpg"   "cyl"   "disp"  "hp"    "drat"  "wt"    "qsec"  "vs"    "am"   
      [10] "gear"  "carb"  "test"  "label"

# Tokenizer works

    Code
      class(ft_tokenizer(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ft_tokenizer(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

---

    Code
      dplyr::pull(x, token_x)
    Output
      [[1]]
       [1] "this"    "has"     "been"    "the"     "best"    "tv"      "i've"   
       [8] "ever"    "used."   "great"   "screen," "and"     "sound." 
      

# Stop words remover works

    Code
      class(ft_tokenizer(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ft_tokenizer(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

---

    Code
      dplyr::pull(x, stop_x)
    Output
      [[1]]
      [1] "best"    "tv"      "ever"    "used."   "great"   "screen," "sound." 
      

# Hashing TF works

    Code
      class(ft_hashing_tf(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ft_hashing_tf(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

---

    Code
      dplyr::pull(x, hashed_x)
    Output
      [[1]]
      SparseVector(1024, {26: 1.0, 139: 1.0, 515: 1.0, 713: 1.0, 723: 1.0, 750: 1.0, 806: 1.0})
      

# Normalizer works

    Code
      class(ft_hashing_tf(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ft_hashing_tf(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

---

    Code
      dplyr::pull(x, normal_x)
    Output
      [[1]]
      SparseVector(1024, {26: 0.378, 139: 0.378, 515: 0.378, 713: 0.378, 723: 0.378, 750: 0.378, 806: 0.378})
      

# String indexer works

    Code
      class(ft_string_indexer(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ft_string_indexer(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

---

    Code
      table(dplyr::pull(x))
    Output
      
       0  1  2 
      50 50 50 

