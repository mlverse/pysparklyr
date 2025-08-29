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
      [[1]]
       [1] 1 1 1 1 1 1 1 1 1 1 1 1 1
      

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

