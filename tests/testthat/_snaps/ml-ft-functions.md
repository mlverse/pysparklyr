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
      use_test_table_mtcars() %>% ft_binarizer("mpg", "mpg_new", threshold = 20) %>%
        use_test_pull(TRUE)
    Output
      x
       0  1 
      18 14 

# Bucket Random Projection LSH works

    Code
      class(ft_bucketed_random_projection_lsh(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_bucketed_random_projection_lsh(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      use_test_mtcars_va() %>% ft_bucketed_random_projection_lsh("vec_x", "lsh_x",
        bucket_length = 1) %>% use_test_pull()
    Output
       [1] -1 -1  0 -1 -3 -1 -3  1  1 -1 -1 -3 -3 -3 -3 -3 -2  1  1  1  0 -3 -3 -3 -2
      [26]  1  1  1 -3 -1 -3  0

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
      use_test_table_mtcars() %>% ft_bucketizer("mpg", "mpg_new", splits = c(0, 10,
        20, 30, 40)) %>% use_test_pull(TRUE)
    Output
      x
       1  2  3 
      18 10  4 

# Count vectorizer works

    Code
      class(ft_count_vectorizer(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_count_vectorizer(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      use_test_table_reviews() %>% ft_tokenizer(input_col = "x", output_col = "token_x") %>%
        ft_count_vectorizer("token_x", "cv_x") %>% use_test_pull()
    Output
                                            x
      1 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1

# DCT works

    Code
      class(ft_dct(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_dct(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      use_test_mtcars_va() %>% ft_dct("vec_x", "dct_x") %>% use_test_pull()
    Output
                                                            x
      1  17.1011149733967, 10.6066017177982, 8.88348280049366
      2  17.2483392920401, 10.6066017177982, 8.67527617235709
      3   16.8124398388019, 13.2936074863071, 9.0467821166792
      4  17.6755784912404, 10.8894444302728, 8.56096665102721
      5  17.4013371133753, 7.56604255869606, 8.09148111699377
      6  15.9117734188661, 8.55599205235723, 7.01370563016917
      7  14.9360514639356, 4.45477272147525, 6.18904408343216
      8  18.2384950037003, 14.4249783362056, 8.98962735601427
      9  17.2916405622293, 13.2936074863071, 8.36908995450919
      10 16.5353117095909, 9.33380951166243, 7.47910868129797
      11 15.7270213327254, 8.34386001800126, 6.90756107464856
      12   16.4371621638286, 5.939696961967, 6.63811720294241
      13 16.7604783145748, 6.57609306503489, 7.28314950187532
      14 15.5769102627361, 5.09116882454314, 6.38500326285482
      15 13.6543338663346, 1.69705627484771, 3.22516149466452
      16 13.7547928131736, 1.69705627484771, 3.08309108958309
      17   16.1917882994231, 4.73761543394987, 4.903061968471
      18  22.2857203907196, 20.081832585698, 13.0639452948436
      19 20.7932699448644, 18.6676190233249, 12.7250992137586
      20  22.9410129462498, 21.1424927574778, 13.974338982578
      21 16.1456002778879, 12.3743686707646, 8.39766733484166
      22 15.6000042735037, 5.30330085889911, 6.71976686103519
      23 15.3777244198657, 5.09116882454314, 6.66669458327488
      24  14.5145857674272, 3.7476659402887, 5.56034171611782
      25 17.9238391069919, 7.91959594928933, 7.96492414694997
      26 19.1882361965172, 16.4755880016466, 11.1982506074238
      27  18.5560376517546, 15.556349186104, 10.5001460307306
      28  20.734380217407, 18.6676190233249, 12.8083818650132
      29 15.5711367600442, 5.51543289325507, 7.12801515149905
      30  16.4371621638286, 9.6873629022557, 8.23028553575148
      31 15.3401966523684, 4.94974746830583, 6.47481788675687
      32 16.2697305857637, 12.3036579926459, 8.09964608280304

# Discrete Cosine works

    Code
      class(ft_discrete_cosine_transform(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_discrete_cosine_transform(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      use_test_mtcars_va() %>% ft_discrete_cosine_transform("vec_x", "dct_x") %>%
        use_test_pull()
    Output
                                                            x
      1  17.1011149733967, 10.6066017177982, 8.88348280049366
      2  17.2483392920401, 10.6066017177982, 8.67527617235709
      3   16.8124398388019, 13.2936074863071, 9.0467821166792
      4  17.6755784912404, 10.8894444302728, 8.56096665102721
      5  17.4013371133753, 7.56604255869606, 8.09148111699377
      6  15.9117734188661, 8.55599205235723, 7.01370563016917
      7  14.9360514639356, 4.45477272147525, 6.18904408343216
      8  18.2384950037003, 14.4249783362056, 8.98962735601427
      9  17.2916405622293, 13.2936074863071, 8.36908995450919
      10 16.5353117095909, 9.33380951166243, 7.47910868129797
      11 15.7270213327254, 8.34386001800126, 6.90756107464856
      12   16.4371621638286, 5.939696961967, 6.63811720294241
      13 16.7604783145748, 6.57609306503489, 7.28314950187532
      14 15.5769102627361, 5.09116882454314, 6.38500326285482
      15 13.6543338663346, 1.69705627484771, 3.22516149466452
      16 13.7547928131736, 1.69705627484771, 3.08309108958309
      17   16.1917882994231, 4.73761543394987, 4.903061968471
      18  22.2857203907196, 20.081832585698, 13.0639452948436
      19 20.7932699448644, 18.6676190233249, 12.7250992137586
      20  22.9410129462498, 21.1424927574778, 13.974338982578
      21 16.1456002778879, 12.3743686707646, 8.39766733484166
      22 15.6000042735037, 5.30330085889911, 6.71976686103519
      23 15.3777244198657, 5.09116882454314, 6.66669458327488
      24  14.5145857674272, 3.7476659402887, 5.56034171611782
      25 17.9238391069919, 7.91959594928933, 7.96492414694997
      26 19.1882361965172, 16.4755880016466, 11.1982506074238
      27  18.5560376517546, 15.556349186104, 10.5001460307306
      28  20.734380217407, 18.6676190233249, 12.8083818650132
      29 15.5711367600442, 5.51543289325507, 7.12801515149905
      30  16.4371621638286, 9.6873629022557, 8.23028553575148
      31 15.3401966523684, 4.94974746830583, 6.47481788675687
      32 16.2697305857637, 12.3036579926459, 8.09964608280304

# Elementwise Product works

    Code
      class(ft_elementwise_product(sc, "a", "b"))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_elementwise_product(ml_pipeline(sc), "a", "b"))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      use_test_mtcars_va() %>% ft_elementwise_product("vec_x", "elm_x", scaling_vec = c(
        1:3)) %>% use_test_pull()
    Output
                        x
      1      21, 5.24, 18
      2      21, 5.75, 18
      3    22.8, 4.64, 12
      4    21.4, 6.43, 18
      5    18.7, 6.88, 24
      6    18.1, 6.92, 18
      7    14.3, 7.14, 24
      8    24.4, 6.38, 12
      9     22.8, 6.3, 12
      10   19.2, 6.88, 18
      11   17.8, 6.88, 18
      12   16.4, 8.14, 24
      13   17.3, 7.46, 24
      14   15.2, 7.56, 24
      15   10.4, 10.5, 24
      16 10.4, 10.848, 24
      17  14.7, 10.69, 24
      18    32.4, 4.4, 12
      19   30.4, 3.23, 12
      20   33.9, 3.67, 12
      21   21.5, 4.93, 12
      22   15.5, 7.04, 24
      23   15.2, 6.87, 24
      24   13.3, 7.68, 24
      25   19.2, 7.69, 24
      26   27.3, 3.87, 12
      27     26, 4.28, 12
      28  30.4, 3.026, 12
      29   15.8, 6.34, 24
      30   19.7, 5.54, 18
      31     15, 7.14, 24
      32   21.4, 5.56, 12

# Feature Hasher works

    Code
      class(ft_feature_hasher(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_feature_hasher(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      use_test_table_mtcars() %>% ft_feature_hasher(c("mpg", "wt", "cyl")) %>%
        use_test_pull()
    Output
                      x
      1     2.62, 6, 21
      2    2.875, 6, 21
      3   2.32, 4, 22.8
      4  3.215, 6, 21.4
      5   3.44, 8, 18.7
      6   3.46, 6, 18.1
      7   3.57, 8, 14.3
      8   3.19, 4, 24.4
      9   3.15, 4, 22.8
      10  3.44, 6, 19.2
      11  3.44, 6, 17.8
      12  4.07, 8, 16.4
      13  3.73, 8, 17.3
      14  3.78, 8, 15.2
      15  5.25, 8, 10.4
      16 5.424, 8, 10.4
      17 5.345, 8, 14.7
      18   2.2, 4, 32.4
      19 1.615, 4, 30.4
      20 1.835, 4, 33.9
      21 2.465, 4, 21.5
      22  3.52, 8, 15.5
      23 3.435, 8, 15.2
      24  3.84, 8, 13.3
      25 3.845, 8, 19.2
      26 1.935, 4, 27.3
      27    2.14, 4, 26
      28 1.513, 4, 30.4
      29  3.17, 8, 15.8
      30  2.77, 6, 19.7
      31    3.57, 8, 15
      32  2.78, 4, 21.4

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
      use_test_table_reviews() %>% ft_tokenizer(input_col = "x", output_col = "token_x") %>%
        ft_hashing_tf(input_col = "token_x", output_col = "hashed_x", binary = TRUE,
          num_features = 1024) %>% use_test_pull()
    Output
                                            x
      1 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1

# IDF works

    Code
      class(ft_idf(sc, "a", "b"))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_idf(ml_pipeline(sc), "a", "b"))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      use_test_mtcars_va() %>% ft_idf("vec_x", "idf_x") %>% use_test_pull()
    Output
               x
      1  0, 0, 0
      2  0, 0, 0
      3  0, 0, 0
      4  0, 0, 0
      5  0, 0, 0
      6  0, 0, 0
      7  0, 0, 0
      8  0, 0, 0
      9  0, 0, 0
      10 0, 0, 0
      11 0, 0, 0
      12 0, 0, 0
      13 0, 0, 0
      14 0, 0, 0
      15 0, 0, 0
      16 0, 0, 0
      17 0, 0, 0
      18 0, 0, 0
      19 0, 0, 0
      20 0, 0, 0
      21 0, 0, 0
      22 0, 0, 0
      23 0, 0, 0
      24 0, 0, 0
      25 0, 0, 0
      26 0, 0, 0
      27 0, 0, 0
      28 0, 0, 0
      29 0, 0, 0
      30 0, 0, 0
      31 0, 0, 0
      32 0, 0, 0

# Imputer works

    Code
      class(ft_imputer(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_imputer(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      use_test_table(x = data.frame(x = c(2, 2, 4, NA, 4), y = 1:5), name = "imputer") %>%
        ft_imputer(list(c("x")), list(c("new_x"))) %>% use_test_pull()
    Output
      [1] 2 2 4 3 4

# Index-to-string works

    Code
      class(ft_index_to_string(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ft_index_to_string(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      use_test_table_iris() %>% ft_string_indexer("Species", "species_idx") %>%
        ft_index_to_string("species_idx", "species_x") %>% use_test_pull(TRUE)
    Output
      x
          setosa versicolor  virginica 
              50         50         50 

# Interaction works

    Code
      class(ft_interaction(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_interaction(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      use_test_table_mtcars() %>% ft_interaction(c("mpg", "wt"), c("mpg_wt")) %>%
        use_test_pull()
    Output
               x
      1    55.02
      2   60.375
      3   52.896
      4   68.801
      5   64.328
      6   62.626
      7   51.051
      8   77.836
      9    71.82
      10  66.048
      11  61.232
      12  66.748
      13  64.529
      14  57.456
      15    54.6
      16 56.4096
      17 78.5715
      18   71.28
      19  49.096
      20 62.2065
      21 52.9975
      22   54.56
      23  52.212
      24  51.072
      25  73.824
      26 52.8255
      27   55.64
      28 45.9952
      29  50.086
      30  54.569
      31   53.55
      32  59.492

# Min Hash LSH works

    Code
      class(ft_minhash_lsh(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_minhash_lsh(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      use_test_iris_va() %>% ft_minhash_lsh("vec_x", "hash_x") %>% use_test_pull() %>%
        round() %>% table()
    Output
      .
      225592966 
            150 

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
      use_test_table_mtcars() %>% ft_r_formula(mpg ~ ., features_col = "test") %>%
        dplyr::select(test) %>% use_test_pull()
    Output
                                                   x
      1    6, 160, 110, 3.9, 2.62, 16.46, 0, 1, 4, 4
      2   6, 160, 110, 3.9, 2.875, 17.02, 0, 1, 4, 4
      3    4, 108, 93, 3.85, 2.32, 18.61, 1, 1, 4, 1
      4  6, 258, 110, 3.08, 3.215, 19.44, 1, 0, 3, 1
      5   8, 360, 175, 3.15, 3.44, 17.02, 0, 0, 3, 2
      6   6, 225, 105, 2.76, 3.46, 20.22, 1, 0, 3, 1
      7   8, 360, 245, 3.21, 3.57, 15.84, 0, 0, 3, 4
      8     4, 146.7, 62, 3.69, 3.19, 20, 1, 0, 4, 2
      9   4, 140.8, 95, 3.92, 3.15, 22.9, 1, 0, 4, 2
      10 6, 167.6, 123, 3.92, 3.44, 18.3, 1, 0, 4, 4
      11 6, 167.6, 123, 3.92, 3.44, 18.9, 1, 0, 4, 4
      12 8, 275.8, 180, 3.07, 4.07, 17.4, 0, 0, 3, 3
      13 8, 275.8, 180, 3.07, 3.73, 17.6, 0, 0, 3, 3
      14   8, 275.8, 180, 3.07, 3.78, 18, 0, 0, 3, 3
      15  8, 472, 205, 2.93, 5.25, 17.98, 0, 0, 3, 4
      16    8, 460, 215, 3, 5.424, 17.82, 0, 0, 3, 4
      17 8, 440, 230, 3.23, 5.345, 17.42, 0, 0, 3, 4
      18   4, 78.7, 66, 4.08, 2.2, 19.47, 1, 1, 4, 1
      19 4, 75.7, 52, 4.93, 1.615, 18.52, 1, 1, 4, 2
      20  4, 71.1, 65, 4.22, 1.835, 19.9, 1, 1, 4, 1
      21 4, 120.1, 97, 3.7, 2.465, 20.01, 1, 0, 3, 1
      22  8, 318, 150, 2.76, 3.52, 16.87, 0, 0, 3, 2
      23  8, 304, 150, 3.15, 3.435, 17.3, 0, 0, 3, 2
      24  8, 350, 245, 3.73, 3.84, 15.41, 0, 0, 3, 4
      25 8, 400, 175, 3.08, 3.845, 17.05, 0, 0, 3, 2
      26    4, 79, 66, 4.08, 1.935, 18.9, 1, 1, 4, 1
      27  4, 120.3, 91, 4.43, 2.14, 16.7, 0, 1, 5, 2
      28 4, 95.1, 113, 3.77, 1.513, 16.9, 1, 1, 5, 2
      29   8, 351, 264, 4.22, 3.17, 14.5, 0, 1, 5, 4
      30   6, 145, 175, 3.62, 2.77, 15.5, 0, 1, 5, 6
      31   8, 301, 335, 3.54, 3.57, 14.6, 0, 1, 5, 8
      32   4, 121, 109, 4.11, 2.78, 18.6, 1, 1, 4, 2

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
      use_test_table_reviews() %>% ft_tokenizer(input_col = "x", output_col = "token_x") %>%
        dplyr::pull()
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
      use_test_table_reviews() %>% ft_tokenizer(input_col = "x", output_col = "token_x") %>%
        ft_stop_words_remover(input_col = "token_x", output_col = "stop_x") %>%
        dplyr::pull()
    Output
      [[1]]
      [1] "best"    "tv"      "ever"    "used."   "great"   "screen," "sound." 
      

