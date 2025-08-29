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
      class(ft_elementwise_product(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_elementwise_product(ml_pipeline(sc)))
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
      class(ft_idf(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_idf(ml_pipeline(sc)))
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
      use_test_table_simple() %>% ft_imputer(list(c("x")), list(c("new_x"))) %>%
        use_test_pull()
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

# N-gram works

    Code
      class(ft_ngram(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_ngram(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      use_test_table_reviews() %>% ft_tokenizer("x", "token_x") %>% ft_ngram(
        "token_x", "ngram_x") %>% dplyr::pull()
    Output
      [[1]]
       [1] "this has"      "has been"      "been the"      "the best"     
       [5] "best tv"       "tv i've"       "i've ever"     "ever used."   
       [9] "used. great"   "great screen," "screen, and"   "and sound."   
      

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
      use_test_table_reviews() %>% ft_tokenizer(input_col = "x", output_col = "token_x") %>%
        ft_stop_words_remover(input_col = "token_x", output_col = "stop_x") %>%
        ft_hashing_tf(input_col = "stop_x", output_col = "hashed_x", binary = TRUE,
          num_features = 1024) %>% ft_normalizer(input_col = "hashed_x", output_col = "normal_x") %>%
        use_test_pull()
    Output
                                                                                                                                          x
      1 0.377964473009227, 0.377964473009227, 0.377964473009227, 0.377964473009227, 0.377964473009227, 0.377964473009227, 0.377964473009227

# One hot encoder works

    Code
      class(ft_one_hot_encoder(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_one_hot_encoder(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      use_test_table_simple() %>% ft_one_hot_encoder(list(c("y")), list(c("ohe_x"))) %>%
        use_test_pull()
    Output
        x
      1 1
      2 1
      3 1
      4 1
      5  

# PCA works

    Code
      class(ft_pca(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_pca(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      use_test_mtcars_va() %>% ft_pca("vec_x", "pca_x", k = 2) %>% use_test_pull()
    Output
                                            x
      1  -18.2965611382428, -11.4130761774528
      2  -18.2617800137841, -11.4315523598361
      3  -20.5597961474102, -9.93186792912188
      4  -18.5990547002653, -11.5598967813608
      5   -15.4828380156268, -12.802324457122
      6   -15.400529008955, -10.7220449362106
      7  -11.2449617519589, -11.6709390588744
      8  -21.9757292109226, -10.4097423627978
      9  -20.4465869972111, -9.99200609138934
      10 -16.4582931177907, -11.0057969809874
      11 -15.1155198009654, -10.6428136901066
      12 -13.1909234439444, -12.2516418037903
      13 -14.1005096945151, -12.4603532952263
      14  -12.079529890952, -11.9195011397647
      15  -7.27523270907473, -10.781496756871
      16  -7.25149970650289, -10.794104034262
      17 -11.3865073655057, -11.9032572910663
      18  -29.783752193621, -12.4122015353842
      19 -27.9452965895617, -11.8512674409271
      20 -31.2722226369938, -12.7746659039107
      21 -19.2931577082149, -9.60531808065371
      22  -12.402730137563, -11.9784448130555
      23 -12.1265867063962, -11.8945039518342
      24 -10.2490108812703, -11.4312282963151
      25 -15.9071593050585, -12.9613058716841
      26   -24.92836591531, -11.0707045229062
      27 -23.6535436821245, -10.7485020114694
      28 -27.9592090393452, -11.8438769679738
      29 -12.7382060751594, -12.0308674807993
      30 -17.0292407162151, -11.0868886070705
      31 -11.9163484103716, -11.8524307043147
      32 -19.1542804099927, -9.60221422214842

# Polynomial expansion works

    Code
      class(ft_polynomial_expansion(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_polynomial_expansion(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      use_test_mtcars_va() %>% ft_polynomial_expansion("vec_x", "pe_x", degree = 2) %>%
        use_test_pull()
    Output
                                                                    x
      1               21, 441, 2.62, 55.02, 6.8644, 6, 126, 15.72, 36
      2           21, 441, 2.875, 60.375, 8.265625, 6, 126, 17.25, 36
      3         22.8, 519.84, 2.32, 52.896, 5.3824, 4, 91.2, 9.28, 16
      4   21.4, 457.96, 3.215, 68.801, 10.336225, 6, 128.4, 19.29, 36
      5      18.7, 349.69, 3.44, 64.328, 11.8336, 8, 149.6, 27.52, 64
      6      18.1, 327.61, 3.46, 62.626, 11.9716, 6, 108.6, 20.76, 36
      7      14.3, 204.49, 3.57, 51.051, 12.7449, 8, 114.4, 28.56, 64
      8       24.4, 595.36, 3.19, 77.836, 10.1761, 4, 97.6, 12.76, 16
      9          22.8, 519.84, 3.15, 71.82, 9.9225, 4, 91.2, 12.6, 16
      10     19.2, 368.64, 3.44, 66.048, 11.8336, 6, 115.2, 20.64, 36
      11     17.8, 316.84, 3.44, 61.232, 11.8336, 6, 106.8, 20.64, 36
      12     16.4, 268.96, 4.07, 66.748, 16.5649, 8, 131.2, 32.56, 64
      13     17.3, 299.29, 3.73, 64.529, 13.9129, 8, 138.4, 29.84, 64
      14     15.2, 231.04, 3.78, 57.456, 14.2884, 8, 121.6, 30.24, 64
      15           10.4, 108.16, 5.25, 54.6, 27.5625, 8, 83.2, 42, 64
      16 10.4, 108.16, 5.424, 56.4096, 29.419776, 8, 83.2, 43.392, 64
      17 14.7, 216.09, 5.345, 78.5715, 28.569025, 8, 117.6, 42.76, 64
      18           32.4, 1049.76, 2.2, 71.28, 4.84, 4, 129.6, 8.8, 16
      19    30.4, 924.16, 1.615, 49.096, 2.608225, 4, 121.6, 6.46, 16
      20  33.9, 1149.21, 1.835, 62.2065, 3.367225, 4, 135.6, 7.34, 16
      21      21.5, 462.25, 2.465, 52.9975, 6.076225, 4, 86, 9.86, 16
      22        15.5, 240.25, 3.52, 54.56, 12.3904, 8, 124, 28.16, 64
      23  15.2, 231.04, 3.435, 52.212, 11.799225, 8, 121.6, 27.48, 64
      24     13.3, 176.89, 3.84, 51.072, 14.7456, 8, 106.4, 30.72, 64
      25  19.2, 368.64, 3.845, 73.824, 14.784025, 8, 153.6, 30.76, 64
      26   27.3, 745.29, 1.935, 52.8255, 3.744225, 4, 109.2, 7.74, 16
      27               26, 676, 2.14, 55.64, 4.5796, 4, 104, 8.56, 16
      28  30.4, 924.16, 1.513, 45.9952, 2.289169, 4, 121.6, 6.052, 16
      29     15.8, 249.64, 3.17, 50.086, 10.0489, 8, 126.4, 25.36, 64
      30      19.7, 388.09, 2.77, 54.569, 7.6729, 6, 118.2, 16.62, 36
      31             15, 225, 3.57, 53.55, 12.7449, 8, 120, 28.56, 64
      32       21.4, 457.96, 2.78, 59.492, 7.7284, 4, 85.6, 11.12, 16

# Quantile discretizer works

    Code
      class(ft_quantile_discretizer(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_quantile_discretizer(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      use_test_table_simple() %>% ft_quantile_discretizer(c("y"), c("ohe_x")) %>%
        use_test_pull()
    Output
      [1] 0 0 1 1 1

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

# Regex Tokenizer works

    Code
      class(ft_regex_tokenizer(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_regex_tokenizer(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      use_test_table_reviews() %>% ft_regex_tokenizer("x", "new_x") %>% dplyr::pull()
    Output
      [[1]]
       [1] "this"    "has"     "been"    "the"     "best"    "tv"      "i've"   
       [8] "ever"    "used."   "great"   "screen," "and"     "sound." 
      

# Robust Scaler works

    Code
      class(ft_robust_scaler(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_robust_scaler(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      use_test_mtcars_va() %>% ft_robust_scaler("vec_x", "rs_x") %>% use_test_pull()
    Output
                                                    x
      1      0.236842105263158, -0.538461538461538, 0
      2      0.236842105263158, -0.307692307692308, 0
      3   0.473684210526316, -0.809954751131222, -0.5
      4                       0.289473684210526, 0, 0
      5   -0.0657894736842105, 0.203619909502263, 0.5
      6      -0.144736842105263, 0.221719457013575, 0
      7    -0.644736842105263, 0.321266968325792, 0.5
      8  0.684210526315789, -0.0226244343891402, -0.5
      9  0.473684210526316, -0.0588235294117647, -0.5
      10                      0, 0.203619909502263, 0
      11     -0.184210526315789, 0.203619909502263, 0
      12   -0.368421052631579, 0.773755656108598, 0.5
      13                 -0.25, 0.46606334841629, 0.5
      14    -0.526315789473684, 0.51131221719457, 0.5
      15      -1.1578947368421, 1.84162895927602, 0.5
      16      -1.1578947368421, 1.99909502262443, 0.5
      17    -0.592105263157895, 1.92760180995475, 0.5
      18   1.73684210526316, -0.918552036199095, -0.5
      19    1.47368421052632, -1.44796380090498, -0.5
      20    1.93421052631579, -1.24886877828054, -0.5
      21  0.302631578947368, -0.678733031674208, -0.5
      22   -0.486842105263158, 0.276018099547511, 0.5
      23   -0.526315789473684, 0.199095022624435, 0.5
      24   -0.776315789473684, 0.565610859728507, 0.5
      25                    0, 0.570135746606335, 0.5
      26    1.06578947368421, -1.15837104072398, -0.5
      27  0.894736842105263, -0.972850678733031, -0.5
      28    1.47368421052632, -1.54027149321267, -0.5
      29 -0.447368421052631, -0.0407239819004524, 0.5
      30    0.0657894736842105, -0.402714932126697, 0
      31   -0.552631578947368, 0.321266968325792, 0.5
      32  0.289473684210526, -0.393665158371041, -0.5

# SQL transformer works

    Code
      class(ft_sql_transformer(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_sql_transformer(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      use_test_mtcars_va() %>% ft_sql_transformer(
        "select * from __THIS__ where mpg > 20") %>% use_test_pull()
    Output
                      x
      1     21, 2.62, 6
      2    21, 2.875, 6
      3   22.8, 2.32, 4
      4  21.4, 3.215, 6
      5   24.4, 3.19, 4
      6   22.8, 3.15, 4
      7    32.4, 2.2, 4
      8  30.4, 1.615, 4
      9  33.9, 1.835, 4
      10 21.5, 2.465, 4
      11 27.3, 1.935, 4
      12    26, 2.14, 4
      13 30.4, 1.513, 4
      14  21.4, 2.78, 4

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
      use_test_table_iris() %>% ft_string_indexer("Species", "species_idx") %>%
        use_test_pull(TRUE)
    Output
      x
       0  1  2 
      50 50 50 

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
      

# Vector assembler works

    Code
      class(ft_vector_assembler(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ft_vector_assembler(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      use_test_table_mtcars() %>% ft_vector_assembler(input_cols = c("mpg", "wt",
        "cyl"), output_col = "vec_x") %>% use_test_pull()
    Output
                      x
      1     21, 2.62, 6
      2    21, 2.875, 6
      3   22.8, 2.32, 4
      4  21.4, 3.215, 6
      5   18.7, 3.44, 8
      6   18.1, 3.46, 6
      7   14.3, 3.57, 8
      8   24.4, 3.19, 4
      9   22.8, 3.15, 4
      10  19.2, 3.44, 6
      11  17.8, 3.44, 6
      12  16.4, 4.07, 8
      13  17.3, 3.73, 8
      14  15.2, 3.78, 8
      15  10.4, 5.25, 8
      16 10.4, 5.424, 8
      17 14.7, 5.345, 8
      18   32.4, 2.2, 4
      19 30.4, 1.615, 4
      20 33.9, 1.835, 4
      21 21.5, 2.465, 4
      22  15.5, 3.52, 8
      23 15.2, 3.435, 8
      24  13.3, 3.84, 8
      25 19.2, 3.845, 8
      26 27.3, 1.935, 4
      27    26, 2.14, 4
      28 30.4, 1.513, 4
      29  15.8, 3.17, 8
      30  19.7, 2.77, 6
      31    15, 3.57, 8
      32  21.4, 2.78, 4

# Vector indexer works

    Code
      class(ft_vector_indexer(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ft_vector_indexer(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

# Vector slicer works

    Code
      class(ft_vector_slicer(ml_pipeline(sc)))
    Output
      [1] "ml_connect_pipeline"       "ml_pipeline"              
      [3] "ml_connect_estimator"      "ml_estimator"             
      [5] "ml_connect_pipeline_stage" "ml_pipeline_stage"        

---

    Code
      class(ft_vector_slicer(sc))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      use_test_mtcars_va() %>% ft_vector_slicer("vec_x", "index_x", indices = list(1L)) %>%
        use_test_pull()
    Output
             x
      1   2.62
      2  2.875
      3   2.32
      4  3.215
      5   3.44
      6   3.46
      7   3.57
      8   3.19
      9   3.15
      10  3.44
      11  3.44
      12  4.07
      13  3.73
      14  3.78
      15  5.25
      16 5.424
      17 5.345
      18   2.2
      19 1.615
      20 1.835
      21 2.465
      22  3.52
      23 3.435
      24  3.84
      25 3.845
      26 1.935
      27  2.14
      28 1.513
      29  3.17
      30  2.77
      31  3.57
      32  2.78

