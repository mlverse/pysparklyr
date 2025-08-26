# Binarizer works

    Code
      class(ft_binarizer(sc, "a", "b"))
    Output
      [1] "ml_transformer"    "ml_pipeline_stage"

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

# Bucketizer works

    Code
      class(ft_bucketizer(sc, "a", "b", c(1, 2, 3)))
    Output
      [1] "ml_transformer"    "ml_pipeline_stage"

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
      [1] "ml_transformer"    "ml_pipeline_stage"

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
      [1] "ml_transformer"    "ml_pipeline_stage"

---

    Code
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

---

    Code
      dplyr::pull(x, token_x)
    Output
      [1] "c(\"this\", \"has\", \"been\", \"the\", \"best\", \"tv\", \"i've\", \"ever\", \"used.\", \"great\", \"screen,\", \"and\", \"sound.\")"

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
      [1] "ml_transformer"    "ml_pipeline_stage"

---

    Code
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

---

    Code
      dplyr::pull(x, stop_x)
    Output
      [1] "c(\"best\", \"tv\", \"ever\", \"used.\", \"great\", \"screen,\", \"sound.\")"

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
      [1] "ml_transformer"    "ml_pipeline_stage"

---

    Code
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

---

    Code
      dplyr::pull(x, hashed_x)
    Output
      [1] "<environment>"

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
      [1] "ml_transformer"    "ml_pipeline_stage"

---

    Code
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

---

    Code
      dplyr::pull(x, normal_x)
    Output
      [1] "<environment>"

