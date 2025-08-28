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
      dplyr::pull(x)
    Output
      [[1]]
           [,1]
      [1,]    1
      
      [[2]]
           [,1]
      [1,]    1
      
      [[3]]
           [,1]
      [1,]    1
      
      [[4]]
           [,1]
      [1,]    1
      
      [[5]]
           [,1]
      [1,]    1
      
      [[6]]
           [,1]
      [1,]    1
      
      [[7]]
           [,1]
      [1,]    1
      
      [[8]]
           [,1]
      [1,]    1
      
      [[9]]
           [,1]
      [1,]    1
      
      [[10]]
           [,1]
      [1,]    1
      
      [[11]]
           [,1]
      [1,]    1
      
      [[12]]
           [,1]
      [1,]    1
      
      [[13]]
           [,1]
      [1,]    1
      
      [[14]]
           [,1]
      [1,]    1
      
      [[15]]
           [,1]
      [1,]    2
      
      [[16]]
           [,1]
      [1,]    1
      
      [[17]]
           [,1]
      [1,]    1
      
      [[18]]
           [,1]
      [1,]    1
      
      [[19]]
           [,1]
      [1,]    1
      
      [[20]]
           [,1]
      [1,]    1
      
      [[21]]
           [,1]
      [1,]    1
      
      [[22]]
           [,1]
      [1,]    1
      
      [[23]]
           [,1]
      [1,]    1
      
      [[24]]
           [,1]
      [1,]    1
      
      [[25]]
           [,1]
      [1,]    0
      
      [[26]]
           [,1]
      [1,]    1
      
      [[27]]
           [,1]
      [1,]    1
      
      [[28]]
           [,1]
      [1,]    1
      
      [[29]]
           [,1]
      [1,]    1
      
      [[30]]
           [,1]
      [1,]    1
      
      [[31]]
           [,1]
      [1,]    1
      
      [[32]]
           [,1]
      [1,]    1
      
      [[33]]
           [,1]
      [1,]    1
      
      [[34]]
           [,1]
      [1,]    1
      
      [[35]]
           [,1]
      [1,]    1
      
      [[36]]
           [,1]
      [1,]    1
      
      [[37]]
           [,1]
      [1,]    1
      
      [[38]]
           [,1]
      [1,]    1
      
      [[39]]
           [,1]
      [1,]    1
      
      [[40]]
           [,1]
      [1,]    1
      
      [[41]]
           [,1]
      [1,]    1
      
      [[42]]
           [,1]
      [1,]    0
      
      [[43]]
           [,1]
      [1,]    1
      
      [[44]]
           [,1]
      [1,]    1
      
      [[45]]
           [,1]
      [1,]    1
      
      [[46]]
           [,1]
      [1,]    1
      
      [[47]]
           [,1]
      [1,]    1
      
      [[48]]
           [,1]
      [1,]    1
      
      [[49]]
           [,1]
      [1,]    1
      
      [[50]]
           [,1]
      [1,]    1
      
      [[51]]
           [,1]
      [1,]   -2
      
      [[52]]
           [,1]
      [1,]   -2
      
      [[53]]
           [,1]
      [1,]   -2
      
      [[54]]
           [,1]
      [1,]   -2
      
      [[55]]
           [,1]
      [1,]   -2
      
      [[56]]
           [,1]
      [1,]   -2
      
      [[57]]
           [,1]
      [1,]   -2
      
      [[58]]
           [,1]
      [1,]   -1
      
      [[59]]
           [,1]
      [1,]   -2
      
      [[60]]
           [,1]
      [1,]   -1
      
      [[61]]
           [,1]
      [1,]   -2
      
      [[62]]
           [,1]
      [1,]   -1
      
      [[63]]
           [,1]
      [1,]   -2
      
      [[64]]
           [,1]
      [1,]   -2
      
      [[65]]
           [,1]
      [1,]   -1
      
      [[66]]
           [,1]
      [1,]   -1
      
      [[67]]
           [,1]
      [1,]   -2
      
      [[68]]
           [,1]
      [1,]   -2
      
      [[69]]
           [,1]
      [1,]   -2
      
      [[70]]
           [,1]
      [1,]   -2
      
      [[71]]
           [,1]
      [1,]   -2
      
      [[72]]
           [,1]
      [1,]   -1
      
      [[73]]
           [,1]
      [1,]   -2
      
      [[74]]
           [,1]
      [1,]   -2
      
      [[75]]
           [,1]
      [1,]   -2
      
      [[76]]
           [,1]
      [1,]   -2
      
      [[77]]
           [,1]
      [1,]   -2
      
      [[78]]
           [,1]
      [1,]   -2
      
      [[79]]
           [,1]
      [1,]   -2
      
      [[80]]
           [,1]
      [1,]   -1
      
      [[81]]
           [,1]
      [1,]   -2
      
      [[82]]
           [,1]
      [1,]   -1
      
      [[83]]
           [,1]
      [1,]   -1
      
      [[84]]
           [,1]
      [1,]   -2
      
      [[85]]
           [,1]
      [1,]   -2
      
      [[86]]
           [,1]
      [1,]   -1
      
      [[87]]
           [,1]
      [1,]   -2
      
      [[88]]
           [,1]
      [1,]   -2
      
      [[89]]
           [,1]
      [1,]   -1
      
      [[90]]
           [,1]
      [1,]   -2
      
      [[91]]
           [,1]
      [1,]   -2
      
      [[92]]
           [,1]
      [1,]   -2
      
      [[93]]
           [,1]
      [1,]   -2
      
      [[94]]
           [,1]
      [1,]   -1
      
      [[95]]
           [,1]
      [1,]   -2
      
      [[96]]
           [,1]
      [1,]   -1
      
      [[97]]
           [,1]
      [1,]   -2
      
      [[98]]
           [,1]
      [1,]   -2
      
      [[99]]
           [,1]
      [1,]   -1
      
      [[100]]
           [,1]
      [1,]   -2
      
      [[101]]
           [,1]
      [1,]   -3
      
      [[102]]
           [,1]
      [1,]   -2
      
      [[103]]
           [,1]
      [1,]   -3
      
      [[104]]
           [,1]
      [1,]   -3
      
      [[105]]
           [,1]
      [1,]   -3
      
      [[106]]
           [,1]
      [1,]   -3
      
      [[107]]
           [,1]
      [1,]   -2
      
      [[108]]
           [,1]
      [1,]   -3
      
      [[109]]
           [,1]
      [1,]   -3
      
      [[110]]
           [,1]
      [1,]   -3
      
      [[111]]
           [,1]
      [1,]   -2
      
      [[112]]
           [,1]
      [1,]   -2
      
      [[113]]
           [,1]
      [1,]   -2
      
      [[114]]
           [,1]
      [1,]   -2
      
      [[115]]
           [,1]
      [1,]   -2
      
      [[116]]
           [,1]
      [1,]   -2
      
      [[117]]
           [,1]
      [1,]   -2
      
      [[118]]
           [,1]
      [1,]   -3
      
      [[119]]
           [,1]
      [1,]   -4
      
      [[120]]
           [,1]
      [1,]   -3
      
      [[121]]
           [,1]
      [1,]   -2
      
      [[122]]
           [,1]
      [1,]   -2
      
      [[123]]
           [,1]
      [1,]   -3
      
      [[124]]
           [,1]
      [1,]   -2
      
      [[125]]
           [,1]
      [1,]   -2
      
      [[126]]
           [,1]
      [1,]   -3
      
      [[127]]
           [,1]
      [1,]   -2
      
      [[128]]
           [,1]
      [1,]   -2
      
      [[129]]
           [,1]
      [1,]   -3
      
      [[130]]
           [,1]
      [1,]   -3
      
      [[131]]
           [,1]
      [1,]   -3
      
      [[132]]
           [,1]
      [1,]   -3
      
      [[133]]
           [,1]
      [1,]   -3
      
      [[134]]
           [,1]
      [1,]   -2
      
      [[135]]
           [,1]
      [1,]   -3
      
      [[136]]
           [,1]
      [1,]   -3
      
      [[137]]
           [,1]
      [1,]   -2
      
      [[138]]
           [,1]
      [1,]   -2
      
      [[139]]
           [,1]
      [1,]   -2
      
      [[140]]
           [,1]
      [1,]   -2
      
      [[141]]
           [,1]
      [1,]   -2
      
      [[142]]
           [,1]
      [1,]   -2
      
      [[143]]
           [,1]
      [1,]   -2
      
      [[144]]
           [,1]
      [1,]   -3
      
      [[145]]
           [,1]
      [1,]   -2
      
      [[146]]
           [,1]
      [1,]   -2
      
      [[147]]
           [,1]
      [1,]   -2
      
      [[148]]
           [,1]
      [1,]   -2
      
      [[149]]
           [,1]
      [1,]   -2
      
      [[150]]
           [,1]
      [1,]   -2
      

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
      

# DCT works

    Code
      class(ft_dct(sc, "a", "b"))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_dct(ml_pipeline(sc), "a", "b"))
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
      DenseVector([5.7735, 2.6163, -0.2041])
      
      [[2]]
      DenseVector([5.3694, 2.4749, 0.1225])
      
      [[3]]
      DenseVector([5.3116, 2.4042, -0.1633])
      
      [[4]]
      DenseVector([5.3116, 2.192, -0.0408])
      
      [[5]]
      DenseVector([5.7735, 2.5456, -0.3266])
      
      [[6]]
      DenseVector([6.3509, 2.6163, -0.2858])
      
      [[7]]
      DenseVector([5.4271, 2.2627, -0.3266])
      
      [[8]]
      DenseVector([5.7158, 2.4749, -0.1225])
      
      [[9]]
      DenseVector([5.0229, 2.1213, 0.0])
      
      [[10]]
      DenseVector([5.4848, 2.4042, 0.0816])
      
      [[11]]
      DenseVector([6.1199, 2.7577, -0.2041])
      
      [[12]]
      DenseVector([5.658, 2.2627, -0.1633])
      
      [[13]]
      DenseVector([5.3116, 2.4042, 0.0816])
      
      [[14]]
      DenseVector([4.8497, 2.2627, -0.2449])
      
      [[15]]
      DenseVector([6.3509, 3.2527, -0.4082])
      
      [[16]]
      DenseVector([6.6973, 2.9698, -0.6532])
      
      [[17]]
      DenseVector([6.1199, 2.8991, -0.4491])
      
      [[18]]
      DenseVector([5.7735, 2.6163, -0.2041])
      
      [[19]]
      DenseVector([6.4663, 2.8284, -0.0816])
      
      [[20]]
      DenseVector([6.0044, 2.5456, -0.4082])
      
      [[21]]
      DenseVector([6.0622, 2.6163, 0.1225])
      
      [[22]]
      DenseVector([5.9467, 2.5456, -0.3266])
      
      [[23]]
      DenseVector([5.3116, 2.5456, -0.6532])
      
      [[24]]
      DenseVector([5.8312, 2.4042, 0.0816])
      
      [[25]]
      DenseVector([5.8312, 2.0506, -0.0408])
      
      [[26]]
      DenseVector([5.5426, 2.4042, 0.2449])
      
      [[27]]
      DenseVector([5.7735, 2.4042, -0.0816])
      
      [[28]]
      DenseVector([5.889, 2.6163, -0.1225])
      
      [[29]]
      DenseVector([5.7735, 2.687, -0.0816])
      
      [[30]]
      DenseVector([5.4848, 2.192, -0.0408])
      
      [[31]]
      DenseVector([5.4848, 2.2627, 0.0816])
      
      [[32]]
      DenseVector([5.9467, 2.7577, 0.0408])
      
      [[33]]
      DenseVector([6.2354, 2.6163, -0.6124])
      
      [[34]]
      DenseVector([6.4086, 2.8991, -0.6124])
      
      [[35]]
      DenseVector([5.4848, 2.4042, 0.0816])
      
      [[36]]
      DenseVector([5.4271, 2.687, -0.0816])
      
      [[37]]
      DenseVector([5.9467, 2.9698, -0.0816])
      
      [[38]]
      DenseVector([5.7158, 2.4749, -0.3674])
      
      [[39]]
      DenseVector([5.0229, 2.192, -0.1225])
      
      [[40]]
      DenseVector([5.7735, 2.5456, -0.0816])
      
      [[41]]
      DenseVector([5.658, 2.6163, -0.2858])
      
      [[42]]
      DenseVector([4.6765, 2.2627, 0.4899])
      
      [[43]]
      DenseVector([5.1384, 2.192, -0.2858])
      
      [[44]]
      DenseVector([5.8312, 2.4042, -0.1633])
      
      [[45]]
      DenseVector([6.2354, 2.2627, -0.2449])
      
      [[46]]
      DenseVector([5.3116, 2.4042, 0.0816])
      
      [[47]]
      DenseVector([6.0622, 2.4749, -0.3674])
      
      [[48]]
      DenseVector([5.3116, 2.2627, -0.1633])
      
      [[49]]
      DenseVector([6.0622, 2.687, -0.2449])
      
      [[50]]
      DenseVector([5.6003, 2.5456, -0.0816])
      
      [[51]]
      DenseVector([8.6025, 1.6263, 2.1637])
      
      [[52]]
      DenseVector([8.1406, 1.3435, 1.8371])
      
      [[53]]
      DenseVector([8.6025, 1.4142, 2.2862])
      
      [[54]]
      DenseVector([6.8127, 1.0607, 2.0004])
      
      [[55]]
      DenseVector([8.0252, 1.3435, 2.2454])
      
      [[56]]
      DenseVector([7.5056, 0.8485, 1.8779])
      
      [[57]]
      DenseVector([8.2561, 1.1314, 1.7963])
      
      [[58]]
      DenseVector([6.1199, 1.1314, 1.388])
      
      [[59]]
      DenseVector([8.1406, 1.4142, 2.2045])
      
      [[60]]
      DenseVector([6.8127, 0.9192, 1.5105])
      
      [[61]]
      DenseVector([6.0622, 1.0607, 1.8371])
      
      [[62]]
      DenseVector([7.5633, 1.2021, 1.6738])
      
      [[63]]
      DenseVector([7.0437, 1.4142, 2.2862])
      
      [[64]]
      DenseVector([7.9097, 0.9899, 2.0412])
      
      [[65]]
      DenseVector([6.9859, 1.4142, 1.388])
      
      [[66]]
      DenseVector([8.1984, 1.6263, 2.0004])
      
      [[67]]
      DenseVector([7.5633, 0.7778, 1.6738])
      
      [[68]]
      DenseVector([7.2746, 1.2021, 1.8371])
      
      [[69]]
      DenseVector([7.4478, 1.2021, 2.572])
      
      [[70]]
      DenseVector([6.9282, 1.2021, 1.8371])
      
      [[71]]
      DenseVector([8.0252, 0.7778, 1.7555])
      
      [[72]]
      DenseVector([7.4478, 1.4849, 1.8371])
      
      [[73]]
      DenseVector([7.9097, 0.9899, 2.5311])
      
      [[74]]
      DenseVector([7.852, 0.9899, 2.1229])
      
      [[75]]
      DenseVector([7.852, 1.4849, 2.0004])
      
      [[76]]
      DenseVector([8.0829, 1.5556, 2.0412])
      
      [[77]]
      DenseVector([8.3138, 1.4142, 2.4495])
      
      [[78]]
      DenseVector([8.487, 1.2021, 2.327])
      
      [[79]]
      DenseVector([7.7365, 1.0607, 1.9188])
      
      [[80]]
      DenseVector([6.8127, 1.5556, 1.633])
      
      [[81]]
      DenseVector([6.755, 1.2021, 1.8371])
      
      [[82]]
      DenseVector([6.6973, 1.2728, 1.7963])
      
      [[83]]
      DenseVector([7.1591, 1.3435, 1.7555])
      
      [[84]]
      DenseVector([7.9674, 0.6364, 2.327])
      
      [[85]]
      DenseVector([7.4478, 0.6364, 1.5922])
      
      [[86]]
      DenseVector([8.0252, 1.0607, 1.5105])
      
      [[87]]
      DenseVector([8.3716, 1.4142, 2.1229])
      
      [[88]]
      DenseVector([7.5056, 1.3435, 2.4903])
      
      [[89]]
      DenseVector([7.3323, 1.0607, 1.5105])
      
      [[90]]
      DenseVector([6.9282, 1.0607, 1.8371])
      
      [[91]]
      DenseVector([7.2169, 0.7778, 1.9188])
      
      [[92]]
      DenseVector([7.9097, 1.0607, 1.9188])
      
      [[93]]
      DenseVector([7.1591, 1.2728, 1.8779])
      
      [[94]]
      DenseVector([6.1199, 1.2021, 1.5105])
      
      [[95]]
      DenseVector([7.2169, 0.9899, 1.7963])
      
      [[96]]
      DenseVector([7.4478, 1.0607, 1.5922])
      
      [[97]]
      DenseVector([7.3901, 1.0607, 1.6738])
      
      [[98]]
      DenseVector([7.7365, 1.3435, 1.9188])
      
      [[99]]
      DenseVector([6.1199, 1.4849, 1.2656])
      
      [[100]]
      DenseVector([7.2746, 1.1314, 1.7146])
      
      [[101]]
      DenseVector([9.0067, 0.2121, 2.327])
      
      [[102]]
      DenseVector([7.852, 0.495, 2.2454])
      
      [[103]]
      DenseVector([9.2376, 0.8485, 2.8577])
      
      [[104]]
      DenseVector([8.5448, 0.495, 2.4903])
      
      [[105]]
      DenseVector([8.8335, 0.495, 2.572])
      
      [[106]]
      DenseVector([9.9304, 0.7071, 3.3476])
      
      [[107]]
      DenseVector([6.8705, 0.2828, 1.7963])
      
      [[108]]
      DenseVector([9.5263, 0.7071, 3.1843])
      
      [[109]]
      DenseVector([8.6603, 0.6364, 3.0619])
      
      [[110]]
      DenseVector([9.7572, 0.7778, 2.4903])
      
      [[111]]
      DenseVector([8.5448, 0.9899, 2.1229])
      
      [[112]]
      DenseVector([8.3138, 0.7778, 2.572])
      
      [[113]]
      DenseVector([8.8335, 0.9192, 2.572])
      
      [[114]]
      DenseVector([7.621, 0.495, 2.327])
      
      [[115]]
      DenseVector([7.9097, 0.495, 2.1637])
      
      [[116]]
      DenseVector([8.6025, 0.7778, 2.1637])
      
      [[117]]
      DenseVector([8.6603, 0.7071, 2.4495])
      
      [[118]]
      DenseVector([10.5078, 0.7071, 2.7761])
      
      [[119]]
      DenseVector([9.9304, 0.5657, 3.8375])
      
      [[120]]
      DenseVector([7.621, 0.7071, 2.6944])
      
      [[121]]
      DenseVector([9.1221, 0.8485, 2.5311])
      
      [[122]]
      DenseVector([7.6788, 0.495, 2.0004])
      
      [[123]]
      DenseVector([9.9304, 0.7071, 3.5926])
      
      [[124]]
      DenseVector([8.0252, 0.9899, 2.3678])
      
      [[125]]
      DenseVector([9.0644, 0.7071, 2.3678])
      
      [[126]]
      DenseVector([9.4685, 0.8485, 2.7761])
      
      [[127]]
      DenseVector([7.9674, 0.9899, 2.2045])
      
      [[128]]
      DenseVector([8.0829, 0.8485, 2.0412])
      
      [[129]]
      DenseVector([8.5448, 0.5657, 2.6128])
      
      [[130]]
      DenseVector([9.2376, 0.9899, 2.8577])
      
      [[131]]
      DenseVector([9.4108, 0.9192, 3.2252])
      
      [[132]]
      DenseVector([10.45, 1.0607, 2.7353])
      
      [[133]]
      DenseVector([8.5448, 0.5657, 2.6128])
      
      [[134]]
      DenseVector([8.1984, 0.8485, 2.3678])
      
      [[135]]
      DenseVector([8.2561, 0.3536, 2.6536])
      
      [[136]]
      DenseVector([9.6995, 1.1314, 3.1843])
      
      [[137]]
      DenseVector([8.8335, 0.495, 2.0821])
      
      [[138]]
      DenseVector([8.6603, 0.6364, 2.327])
      
      [[139]]
      DenseVector([7.9674, 0.8485, 1.9596])
      
      [[140]]
      DenseVector([8.8912, 1.0607, 2.4903])
      
      [[141]]
      DenseVector([8.8912, 0.7778, 2.4903])
      
      [[142]]
      DenseVector([8.718, 1.2728, 2.3678])
      
      [[143]]
      DenseVector([7.852, 0.495, 2.2454])
      
      [[144]]
      DenseVector([9.1799, 0.6364, 2.572])
      
      [[145]]
      DenseVector([9.0644, 0.7071, 2.3678])
      
      [[146]]
      DenseVector([8.6025, 1.0607, 2.4087])
      
      [[147]]
      DenseVector([7.9674, 0.9192, 2.572])
      
      [[148]]
      DenseVector([8.487, 0.9192, 2.327])
      
      [[149]]
      DenseVector([8.6603, 0.5657, 1.9596])
      
      [[150]]
      DenseVector([8.0829, 0.5657, 2.0412])
      

# Discrete Cosine works

    Code
      class(ft_discrete_cosine_transform(sc, "a", "b"))
    Output
      [1] "ml_transformer"       "ml_connect_estimator" "ml_estimator"        
      [4] "ml_pipeline_stage"   

---

    Code
      class(ft_discrete_cosine_transform(ml_pipeline(sc), "a", "b"))
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
      DenseVector([5.7735, 2.6163, -0.2041])
      
      [[2]]
      DenseVector([5.3694, 2.4749, 0.1225])
      
      [[3]]
      DenseVector([5.3116, 2.4042, -0.1633])
      
      [[4]]
      DenseVector([5.3116, 2.192, -0.0408])
      
      [[5]]
      DenseVector([5.7735, 2.5456, -0.3266])
      
      [[6]]
      DenseVector([6.3509, 2.6163, -0.2858])
      
      [[7]]
      DenseVector([5.4271, 2.2627, -0.3266])
      
      [[8]]
      DenseVector([5.7158, 2.4749, -0.1225])
      
      [[9]]
      DenseVector([5.0229, 2.1213, 0.0])
      
      [[10]]
      DenseVector([5.4848, 2.4042, 0.0816])
      
      [[11]]
      DenseVector([6.1199, 2.7577, -0.2041])
      
      [[12]]
      DenseVector([5.658, 2.2627, -0.1633])
      
      [[13]]
      DenseVector([5.3116, 2.4042, 0.0816])
      
      [[14]]
      DenseVector([4.8497, 2.2627, -0.2449])
      
      [[15]]
      DenseVector([6.3509, 3.2527, -0.4082])
      
      [[16]]
      DenseVector([6.6973, 2.9698, -0.6532])
      
      [[17]]
      DenseVector([6.1199, 2.8991, -0.4491])
      
      [[18]]
      DenseVector([5.7735, 2.6163, -0.2041])
      
      [[19]]
      DenseVector([6.4663, 2.8284, -0.0816])
      
      [[20]]
      DenseVector([6.0044, 2.5456, -0.4082])
      
      [[21]]
      DenseVector([6.0622, 2.6163, 0.1225])
      
      [[22]]
      DenseVector([5.9467, 2.5456, -0.3266])
      
      [[23]]
      DenseVector([5.3116, 2.5456, -0.6532])
      
      [[24]]
      DenseVector([5.8312, 2.4042, 0.0816])
      
      [[25]]
      DenseVector([5.8312, 2.0506, -0.0408])
      
      [[26]]
      DenseVector([5.5426, 2.4042, 0.2449])
      
      [[27]]
      DenseVector([5.7735, 2.4042, -0.0816])
      
      [[28]]
      DenseVector([5.889, 2.6163, -0.1225])
      
      [[29]]
      DenseVector([5.7735, 2.687, -0.0816])
      
      [[30]]
      DenseVector([5.4848, 2.192, -0.0408])
      
      [[31]]
      DenseVector([5.4848, 2.2627, 0.0816])
      
      [[32]]
      DenseVector([5.9467, 2.7577, 0.0408])
      
      [[33]]
      DenseVector([6.2354, 2.6163, -0.6124])
      
      [[34]]
      DenseVector([6.4086, 2.8991, -0.6124])
      
      [[35]]
      DenseVector([5.4848, 2.4042, 0.0816])
      
      [[36]]
      DenseVector([5.4271, 2.687, -0.0816])
      
      [[37]]
      DenseVector([5.9467, 2.9698, -0.0816])
      
      [[38]]
      DenseVector([5.7158, 2.4749, -0.3674])
      
      [[39]]
      DenseVector([5.0229, 2.192, -0.1225])
      
      [[40]]
      DenseVector([5.7735, 2.5456, -0.0816])
      
      [[41]]
      DenseVector([5.658, 2.6163, -0.2858])
      
      [[42]]
      DenseVector([4.6765, 2.2627, 0.4899])
      
      [[43]]
      DenseVector([5.1384, 2.192, -0.2858])
      
      [[44]]
      DenseVector([5.8312, 2.4042, -0.1633])
      
      [[45]]
      DenseVector([6.2354, 2.2627, -0.2449])
      
      [[46]]
      DenseVector([5.3116, 2.4042, 0.0816])
      
      [[47]]
      DenseVector([6.0622, 2.4749, -0.3674])
      
      [[48]]
      DenseVector([5.3116, 2.2627, -0.1633])
      
      [[49]]
      DenseVector([6.0622, 2.687, -0.2449])
      
      [[50]]
      DenseVector([5.6003, 2.5456, -0.0816])
      
      [[51]]
      DenseVector([8.6025, 1.6263, 2.1637])
      
      [[52]]
      DenseVector([8.1406, 1.3435, 1.8371])
      
      [[53]]
      DenseVector([8.6025, 1.4142, 2.2862])
      
      [[54]]
      DenseVector([6.8127, 1.0607, 2.0004])
      
      [[55]]
      DenseVector([8.0252, 1.3435, 2.2454])
      
      [[56]]
      DenseVector([7.5056, 0.8485, 1.8779])
      
      [[57]]
      DenseVector([8.2561, 1.1314, 1.7963])
      
      [[58]]
      DenseVector([6.1199, 1.1314, 1.388])
      
      [[59]]
      DenseVector([8.1406, 1.4142, 2.2045])
      
      [[60]]
      DenseVector([6.8127, 0.9192, 1.5105])
      
      [[61]]
      DenseVector([6.0622, 1.0607, 1.8371])
      
      [[62]]
      DenseVector([7.5633, 1.2021, 1.6738])
      
      [[63]]
      DenseVector([7.0437, 1.4142, 2.2862])
      
      [[64]]
      DenseVector([7.9097, 0.9899, 2.0412])
      
      [[65]]
      DenseVector([6.9859, 1.4142, 1.388])
      
      [[66]]
      DenseVector([8.1984, 1.6263, 2.0004])
      
      [[67]]
      DenseVector([7.5633, 0.7778, 1.6738])
      
      [[68]]
      DenseVector([7.2746, 1.2021, 1.8371])
      
      [[69]]
      DenseVector([7.4478, 1.2021, 2.572])
      
      [[70]]
      DenseVector([6.9282, 1.2021, 1.8371])
      
      [[71]]
      DenseVector([8.0252, 0.7778, 1.7555])
      
      [[72]]
      DenseVector([7.4478, 1.4849, 1.8371])
      
      [[73]]
      DenseVector([7.9097, 0.9899, 2.5311])
      
      [[74]]
      DenseVector([7.852, 0.9899, 2.1229])
      
      [[75]]
      DenseVector([7.852, 1.4849, 2.0004])
      
      [[76]]
      DenseVector([8.0829, 1.5556, 2.0412])
      
      [[77]]
      DenseVector([8.3138, 1.4142, 2.4495])
      
      [[78]]
      DenseVector([8.487, 1.2021, 2.327])
      
      [[79]]
      DenseVector([7.7365, 1.0607, 1.9188])
      
      [[80]]
      DenseVector([6.8127, 1.5556, 1.633])
      
      [[81]]
      DenseVector([6.755, 1.2021, 1.8371])
      
      [[82]]
      DenseVector([6.6973, 1.2728, 1.7963])
      
      [[83]]
      DenseVector([7.1591, 1.3435, 1.7555])
      
      [[84]]
      DenseVector([7.9674, 0.6364, 2.327])
      
      [[85]]
      DenseVector([7.4478, 0.6364, 1.5922])
      
      [[86]]
      DenseVector([8.0252, 1.0607, 1.5105])
      
      [[87]]
      DenseVector([8.3716, 1.4142, 2.1229])
      
      [[88]]
      DenseVector([7.5056, 1.3435, 2.4903])
      
      [[89]]
      DenseVector([7.3323, 1.0607, 1.5105])
      
      [[90]]
      DenseVector([6.9282, 1.0607, 1.8371])
      
      [[91]]
      DenseVector([7.2169, 0.7778, 1.9188])
      
      [[92]]
      DenseVector([7.9097, 1.0607, 1.9188])
      
      [[93]]
      DenseVector([7.1591, 1.2728, 1.8779])
      
      [[94]]
      DenseVector([6.1199, 1.2021, 1.5105])
      
      [[95]]
      DenseVector([7.2169, 0.9899, 1.7963])
      
      [[96]]
      DenseVector([7.4478, 1.0607, 1.5922])
      
      [[97]]
      DenseVector([7.3901, 1.0607, 1.6738])
      
      [[98]]
      DenseVector([7.7365, 1.3435, 1.9188])
      
      [[99]]
      DenseVector([6.1199, 1.4849, 1.2656])
      
      [[100]]
      DenseVector([7.2746, 1.1314, 1.7146])
      
      [[101]]
      DenseVector([9.0067, 0.2121, 2.327])
      
      [[102]]
      DenseVector([7.852, 0.495, 2.2454])
      
      [[103]]
      DenseVector([9.2376, 0.8485, 2.8577])
      
      [[104]]
      DenseVector([8.5448, 0.495, 2.4903])
      
      [[105]]
      DenseVector([8.8335, 0.495, 2.572])
      
      [[106]]
      DenseVector([9.9304, 0.7071, 3.3476])
      
      [[107]]
      DenseVector([6.8705, 0.2828, 1.7963])
      
      [[108]]
      DenseVector([9.5263, 0.7071, 3.1843])
      
      [[109]]
      DenseVector([8.6603, 0.6364, 3.0619])
      
      [[110]]
      DenseVector([9.7572, 0.7778, 2.4903])
      
      [[111]]
      DenseVector([8.5448, 0.9899, 2.1229])
      
      [[112]]
      DenseVector([8.3138, 0.7778, 2.572])
      
      [[113]]
      DenseVector([8.8335, 0.9192, 2.572])
      
      [[114]]
      DenseVector([7.621, 0.495, 2.327])
      
      [[115]]
      DenseVector([7.9097, 0.495, 2.1637])
      
      [[116]]
      DenseVector([8.6025, 0.7778, 2.1637])
      
      [[117]]
      DenseVector([8.6603, 0.7071, 2.4495])
      
      [[118]]
      DenseVector([10.5078, 0.7071, 2.7761])
      
      [[119]]
      DenseVector([9.9304, 0.5657, 3.8375])
      
      [[120]]
      DenseVector([7.621, 0.7071, 2.6944])
      
      [[121]]
      DenseVector([9.1221, 0.8485, 2.5311])
      
      [[122]]
      DenseVector([7.6788, 0.495, 2.0004])
      
      [[123]]
      DenseVector([9.9304, 0.7071, 3.5926])
      
      [[124]]
      DenseVector([8.0252, 0.9899, 2.3678])
      
      [[125]]
      DenseVector([9.0644, 0.7071, 2.3678])
      
      [[126]]
      DenseVector([9.4685, 0.8485, 2.7761])
      
      [[127]]
      DenseVector([7.9674, 0.9899, 2.2045])
      
      [[128]]
      DenseVector([8.0829, 0.8485, 2.0412])
      
      [[129]]
      DenseVector([8.5448, 0.5657, 2.6128])
      
      [[130]]
      DenseVector([9.2376, 0.9899, 2.8577])
      
      [[131]]
      DenseVector([9.4108, 0.9192, 3.2252])
      
      [[132]]
      DenseVector([10.45, 1.0607, 2.7353])
      
      [[133]]
      DenseVector([8.5448, 0.5657, 2.6128])
      
      [[134]]
      DenseVector([8.1984, 0.8485, 2.3678])
      
      [[135]]
      DenseVector([8.2561, 0.3536, 2.6536])
      
      [[136]]
      DenseVector([9.6995, 1.1314, 3.1843])
      
      [[137]]
      DenseVector([8.8335, 0.495, 2.0821])
      
      [[138]]
      DenseVector([8.6603, 0.6364, 2.327])
      
      [[139]]
      DenseVector([7.9674, 0.8485, 1.9596])
      
      [[140]]
      DenseVector([8.8912, 1.0607, 2.4903])
      
      [[141]]
      DenseVector([8.8912, 0.7778, 2.4903])
      
      [[142]]
      DenseVector([8.718, 1.2728, 2.3678])
      
      [[143]]
      DenseVector([7.852, 0.495, 2.2454])
      
      [[144]]
      DenseVector([9.1799, 0.6364, 2.572])
      
      [[145]]
      DenseVector([9.0644, 0.7071, 2.3678])
      
      [[146]]
      DenseVector([8.6025, 1.0607, 2.4087])
      
      [[147]]
      DenseVector([7.9674, 0.9192, 2.572])
      
      [[148]]
      DenseVector([8.487, 0.9192, 2.327])
      
      [[149]]
      DenseVector([8.6603, 0.5657, 1.9596])
      
      [[150]]
      DenseVector([8.0829, 0.5657, 2.0412])
      

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
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

---

    Code
      dplyr::pull(x)
    Output
      [[1]]
      DenseVector([5.1, 7.0, 4.2])
      
      [[2]]
      DenseVector([4.9, 6.0, 4.2])
      
      [[3]]
      DenseVector([4.7, 6.4, 3.9])
      
      [[4]]
      DenseVector([4.6, 6.2, 4.5])
      
      [[5]]
      DenseVector([5.0, 7.2, 4.2])
      
      [[6]]
      DenseVector([5.4, 7.8, 5.1])
      
      [[7]]
      DenseVector([4.6, 6.8, 4.2])
      
      [[8]]
      DenseVector([5.0, 6.8, 4.5])
      
      [[9]]
      DenseVector([4.4, 5.8, 4.2])
      
      [[10]]
      DenseVector([4.9, 6.2, 4.5])
      
      [[11]]
      DenseVector([5.4, 7.4, 4.5])
      
      [[12]]
      DenseVector([4.8, 6.8, 4.8])
      
      [[13]]
      DenseVector([4.8, 6.0, 4.2])
      
      [[14]]
      DenseVector([4.3, 6.0, 3.3])
      
      [[15]]
      DenseVector([5.8, 8.0, 3.6])
      
      [[16]]
      DenseVector([5.7, 8.8, 4.5])
      
      [[17]]
      DenseVector([5.4, 7.8, 3.9])
      
      [[18]]
      DenseVector([5.1, 7.0, 4.2])
      
      [[19]]
      DenseVector([5.7, 7.6, 5.1])
      
      [[20]]
      DenseVector([5.1, 7.6, 4.5])
      
      [[21]]
      DenseVector([5.4, 6.8, 5.1])
      
      [[22]]
      DenseVector([5.1, 7.4, 4.5])
      
      [[23]]
      DenseVector([4.6, 7.2, 3.0])
      
      [[24]]
      DenseVector([5.1, 6.6, 5.1])
      
      [[25]]
      DenseVector([4.8, 6.8, 5.7])
      
      [[26]]
      DenseVector([5.0, 6.0, 4.8])
      
      [[27]]
      DenseVector([5.0, 6.8, 4.8])
      
      [[28]]
      DenseVector([5.2, 7.0, 4.5])
      
      [[29]]
      DenseVector([5.2, 6.8, 4.2])
      
      [[30]]
      DenseVector([4.7, 6.4, 4.8])
      
      [[31]]
      DenseVector([4.8, 6.2, 4.8])
      
      [[32]]
      DenseVector([5.4, 6.8, 4.5])
      
      [[33]]
      DenseVector([5.2, 8.2, 4.5])
      
      [[34]]
      DenseVector([5.5, 8.4, 4.2])
      
      [[35]]
      DenseVector([4.9, 6.2, 4.5])
      
      [[36]]
      DenseVector([5.0, 6.4, 3.6])
      
      [[37]]
      DenseVector([5.5, 7.0, 3.9])
      
      [[38]]
      DenseVector([4.9, 7.2, 4.2])
      
      [[39]]
      DenseVector([4.4, 6.0, 3.9])
      
      [[40]]
      DenseVector([5.1, 6.8, 4.5])
      
      [[41]]
      DenseVector([5.0, 7.0, 3.9])
      
      [[42]]
      DenseVector([4.5, 4.6, 3.9])
      
      [[43]]
      DenseVector([4.4, 6.4, 3.9])
      
      [[44]]
      DenseVector([5.0, 7.0, 4.8])
      
      [[45]]
      DenseVector([5.1, 7.6, 5.7])
      
      [[46]]
      DenseVector([4.8, 6.0, 4.2])
      
      [[47]]
      DenseVector([5.1, 7.6, 4.8])
      
      [[48]]
      DenseVector([4.6, 6.4, 4.2])
      
      [[49]]
      DenseVector([5.3, 7.4, 4.5])
      
      [[50]]
      DenseVector([5.0, 6.6, 4.2])
      
      [[51]]
      DenseVector([7.0, 6.4, 14.1])
      
      [[52]]
      DenseVector([6.4, 6.4, 13.5])
      
      [[53]]
      DenseVector([6.9, 6.2, 14.7])
      
      [[54]]
      DenseVector([5.5, 4.6, 12.0])
      
      [[55]]
      DenseVector([6.5, 5.6, 13.8])
      
      [[56]]
      DenseVector([5.7, 5.6, 13.5])
      
      [[57]]
      DenseVector([6.3, 6.6, 14.1])
      
      [[58]]
      DenseVector([4.9, 4.8, 9.9])
      
      [[59]]
      DenseVector([6.6, 5.8, 13.8])
      
      [[60]]
      DenseVector([5.2, 5.4, 11.7])
      
      [[61]]
      DenseVector([5.0, 4.0, 10.5])
      
      [[62]]
      DenseVector([5.9, 6.0, 12.6])
      
      [[63]]
      DenseVector([6.0, 4.4, 12.0])
      
      [[64]]
      DenseVector([6.1, 5.8, 14.1])
      
      [[65]]
      DenseVector([5.6, 5.8, 10.8])
      
      [[66]]
      DenseVector([6.7, 6.2, 13.2])
      
      [[67]]
      DenseVector([5.6, 6.0, 13.5])
      
      [[68]]
      DenseVector([5.8, 5.4, 12.3])
      
      [[69]]
      DenseVector([6.2, 4.4, 13.5])
      
      [[70]]
      DenseVector([5.6, 5.0, 11.7])
      
      [[71]]
      DenseVector([5.9, 6.4, 14.4])
      
      [[72]]
      DenseVector([6.1, 5.6, 12.0])
      
      [[73]]
      DenseVector([6.3, 5.0, 14.7])
      
      [[74]]
      DenseVector([6.1, 5.6, 14.1])
      
      [[75]]
      DenseVector([6.4, 5.8, 12.9])
      
      [[76]]
      DenseVector([6.6, 6.0, 13.2])
      
      [[77]]
      DenseVector([6.8, 5.6, 14.4])
      
      [[78]]
      DenseVector([6.7, 6.0, 15.0])
      
      [[79]]
      DenseVector([6.0, 5.8, 13.5])
      
      [[80]]
      DenseVector([5.7, 5.2, 10.5])
      
      [[81]]
      DenseVector([5.5, 4.8, 11.4])
      
      [[82]]
      DenseVector([5.5, 4.8, 11.1])
      
      [[83]]
      DenseVector([5.8, 5.4, 11.7])
      
      [[84]]
      DenseVector([6.0, 5.4, 15.3])
      
      [[85]]
      DenseVector([5.4, 6.0, 13.5])
      
      [[86]]
      DenseVector([6.0, 6.8, 13.5])
      
      [[87]]
      DenseVector([6.7, 6.2, 14.1])
      
      [[88]]
      DenseVector([6.3, 4.6, 13.2])
      
      [[89]]
      DenseVector([5.6, 6.0, 12.3])
      
      [[90]]
      DenseVector([5.5, 5.0, 12.0])
      
      [[91]]
      DenseVector([5.5, 5.2, 13.2])
      
      [[92]]
      DenseVector([6.1, 6.0, 13.8])
      
      [[93]]
      DenseVector([5.8, 5.2, 12.0])
      
      [[94]]
      DenseVector([5.0, 4.6, 9.9])
      
      [[95]]
      DenseVector([5.6, 5.4, 12.6])
      
      [[96]]
      DenseVector([5.7, 6.0, 12.6])
      
      [[97]]
      DenseVector([5.7, 5.8, 12.6])
      
      [[98]]
      DenseVector([6.2, 5.8, 12.9])
      
      [[99]]
      DenseVector([5.1, 5.0, 9.0])
      
      [[100]]
      DenseVector([5.7, 5.6, 12.3])
      
      [[101]]
      DenseVector([6.3, 6.6, 18.0])
      
      [[102]]
      DenseVector([5.8, 5.4, 15.3])
      
      [[103]]
      DenseVector([7.1, 6.0, 17.7])
      
      [[104]]
      DenseVector([6.3, 5.8, 16.8])
      
      [[105]]
      DenseVector([6.5, 6.0, 17.4])
      
      [[106]]
      DenseVector([7.6, 6.0, 19.8])
      
      [[107]]
      DenseVector([4.9, 5.0, 13.5])
      
      [[108]]
      DenseVector([7.3, 5.8, 18.9])
      
      [[109]]
      DenseVector([6.7, 5.0, 17.4])
      
      [[110]]
      DenseVector([7.2, 7.2, 18.3])
      
      [[111]]
      DenseVector([6.5, 6.4, 15.3])
      
      [[112]]
      DenseVector([6.4, 5.4, 15.9])
      
      [[113]]
      DenseVector([6.8, 6.0, 16.5])
      
      [[114]]
      DenseVector([5.7, 5.0, 15.0])
      
      [[115]]
      DenseVector([5.8, 5.6, 15.3])
      
      [[116]]
      DenseVector([6.4, 6.4, 15.9])
      
      [[117]]
      DenseVector([6.5, 6.0, 16.5])
      
      [[118]]
      DenseVector([7.7, 7.6, 20.1])
      
      [[119]]
      DenseVector([7.7, 5.2, 20.7])
      
      [[120]]
      DenseVector([6.0, 4.4, 15.0])
      
      [[121]]
      DenseVector([6.9, 6.4, 17.1])
      
      [[122]]
      DenseVector([5.6, 5.6, 14.7])
      
      [[123]]
      DenseVector([7.7, 5.6, 20.1])
      
      [[124]]
      DenseVector([6.3, 5.4, 14.7])
      
      [[125]]
      DenseVector([6.7, 6.6, 17.1])
      
      [[126]]
      DenseVector([7.2, 6.4, 18.0])
      
      [[127]]
      DenseVector([6.2, 5.6, 14.4])
      
      [[128]]
      DenseVector([6.1, 6.0, 14.7])
      
      [[129]]
      DenseVector([6.4, 5.6, 16.8])
      
      [[130]]
      DenseVector([7.2, 6.0, 17.4])
      
      [[131]]
      DenseVector([7.4, 5.6, 18.3])
      
      [[132]]
      DenseVector([7.9, 7.6, 19.2])
      
      [[133]]
      DenseVector([6.4, 5.6, 16.8])
      
      [[134]]
      DenseVector([6.3, 5.6, 15.3])
      
      [[135]]
      DenseVector([6.1, 5.2, 16.8])
      
      [[136]]
      DenseVector([7.7, 6.0, 18.3])
      
      [[137]]
      DenseVector([6.3, 6.8, 16.8])
      
      [[138]]
      DenseVector([6.4, 6.2, 16.5])
      
      [[139]]
      DenseVector([6.0, 6.0, 14.4])
      
      [[140]]
      DenseVector([6.9, 6.2, 16.2])
      
      [[141]]
      DenseVector([6.7, 6.2, 16.8])
      
      [[142]]
      DenseVector([6.9, 6.2, 15.3])
      
      [[143]]
      DenseVector([5.8, 5.4, 15.3])
      
      [[144]]
      DenseVector([6.8, 6.4, 17.7])
      
      [[145]]
      DenseVector([6.7, 6.6, 17.1])
      
      [[146]]
      DenseVector([6.7, 6.0, 15.6])
      
      [[147]]
      DenseVector([6.3, 5.0, 15.0])
      
      [[148]]
      DenseVector([6.5, 6.0, 15.6])
      
      [[149]]
      DenseVector([6.2, 6.8, 16.2])
      
      [[150]]
      DenseVector([5.9, 6.0, 15.3])
      

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
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

---

    Code
      dplyr::pull(x)
    Output
      [[1]]
      SparseVector(262144, {28221: 1.0, 101777: 3.5, 156275: 1.4})
      
      [[2]]
      SparseVector(262144, {28221: 1.0, 101777: 3.0, 156275: 1.4})
      
      [[3]]
      SparseVector(262144, {28221: 1.0, 101777: 3.2, 156275: 1.3})
      
      [[4]]
      SparseVector(262144, {28221: 1.0, 101777: 3.1, 156275: 1.5})
      
      [[5]]
      SparseVector(262144, {28221: 1.0, 101777: 3.6, 156275: 1.4})
      
      [[6]]
      SparseVector(262144, {28221: 1.0, 101777: 3.9, 156275: 1.7})
      
      [[7]]
      SparseVector(262144, {28221: 1.0, 101777: 3.4, 156275: 1.4})
      
      [[8]]
      SparseVector(262144, {28221: 1.0, 101777: 3.4, 156275: 1.5})
      
      [[9]]
      SparseVector(262144, {28221: 1.0, 101777: 2.9, 156275: 1.4})
      
      [[10]]
      SparseVector(262144, {28221: 1.0, 101777: 3.1, 156275: 1.5})
      
      [[11]]
      SparseVector(262144, {28221: 1.0, 101777: 3.7, 156275: 1.5})
      
      [[12]]
      SparseVector(262144, {28221: 1.0, 101777: 3.4, 156275: 1.6})
      
      [[13]]
      SparseVector(262144, {28221: 1.0, 101777: 3.0, 156275: 1.4})
      
      [[14]]
      SparseVector(262144, {28221: 1.0, 101777: 3.0, 156275: 1.1})
      
      [[15]]
      SparseVector(262144, {28221: 1.0, 101777: 4.0, 156275: 1.2})
      
      [[16]]
      SparseVector(262144, {28221: 1.0, 101777: 4.4, 156275: 1.5})
      
      [[17]]
      SparseVector(262144, {28221: 1.0, 101777: 3.9, 156275: 1.3})
      
      [[18]]
      SparseVector(262144, {28221: 1.0, 101777: 3.5, 156275: 1.4})
      
      [[19]]
      SparseVector(262144, {28221: 1.0, 101777: 3.8, 156275: 1.7})
      
      [[20]]
      SparseVector(262144, {28221: 1.0, 101777: 3.8, 156275: 1.5})
      
      [[21]]
      SparseVector(262144, {28221: 1.0, 101777: 3.4, 156275: 1.7})
      
      [[22]]
      SparseVector(262144, {28221: 1.0, 101777: 3.7, 156275: 1.5})
      
      [[23]]
      SparseVector(262144, {28221: 1.0, 101777: 3.6, 156275: 1.0})
      
      [[24]]
      SparseVector(262144, {28221: 1.0, 101777: 3.3, 156275: 1.7})
      
      [[25]]
      SparseVector(262144, {28221: 1.0, 101777: 3.4, 156275: 1.9})
      
      [[26]]
      SparseVector(262144, {28221: 1.0, 101777: 3.0, 156275: 1.6})
      
      [[27]]
      SparseVector(262144, {28221: 1.0, 101777: 3.4, 156275: 1.6})
      
      [[28]]
      SparseVector(262144, {28221: 1.0, 101777: 3.5, 156275: 1.5})
      
      [[29]]
      SparseVector(262144, {28221: 1.0, 101777: 3.4, 156275: 1.4})
      
      [[30]]
      SparseVector(262144, {28221: 1.0, 101777: 3.2, 156275: 1.6})
      
      [[31]]
      SparseVector(262144, {28221: 1.0, 101777: 3.1, 156275: 1.6})
      
      [[32]]
      SparseVector(262144, {28221: 1.0, 101777: 3.4, 156275: 1.5})
      
      [[33]]
      SparseVector(262144, {28221: 1.0, 101777: 4.1, 156275: 1.5})
      
      [[34]]
      SparseVector(262144, {28221: 1.0, 101777: 4.2, 156275: 1.4})
      
      [[35]]
      SparseVector(262144, {28221: 1.0, 101777: 3.1, 156275: 1.5})
      
      [[36]]
      SparseVector(262144, {28221: 1.0, 101777: 3.2, 156275: 1.2})
      
      [[37]]
      SparseVector(262144, {28221: 1.0, 101777: 3.5, 156275: 1.3})
      
      [[38]]
      SparseVector(262144, {28221: 1.0, 101777: 3.6, 156275: 1.4})
      
      [[39]]
      SparseVector(262144, {28221: 1.0, 101777: 3.0, 156275: 1.3})
      
      [[40]]
      SparseVector(262144, {28221: 1.0, 101777: 3.4, 156275: 1.5})
      
      [[41]]
      SparseVector(262144, {28221: 1.0, 101777: 3.5, 156275: 1.3})
      
      [[42]]
      SparseVector(262144, {28221: 1.0, 101777: 2.3, 156275: 1.3})
      
      [[43]]
      SparseVector(262144, {28221: 1.0, 101777: 3.2, 156275: 1.3})
      
      [[44]]
      SparseVector(262144, {28221: 1.0, 101777: 3.5, 156275: 1.6})
      
      [[45]]
      SparseVector(262144, {28221: 1.0, 101777: 3.8, 156275: 1.9})
      
      [[46]]
      SparseVector(262144, {28221: 1.0, 101777: 3.0, 156275: 1.4})
      
      [[47]]
      SparseVector(262144, {28221: 1.0, 101777: 3.8, 156275: 1.6})
      
      [[48]]
      SparseVector(262144, {28221: 1.0, 101777: 3.2, 156275: 1.4})
      
      [[49]]
      SparseVector(262144, {28221: 1.0, 101777: 3.7, 156275: 1.5})
      
      [[50]]
      SparseVector(262144, {28221: 1.0, 101777: 3.3, 156275: 1.4})
      
      [[51]]
      SparseVector(262144, {101777: 3.2, 156275: 4.7, 159347: 1.0})
      
      [[52]]
      SparseVector(262144, {101777: 3.2, 156275: 4.5, 159347: 1.0})
      
      [[53]]
      SparseVector(262144, {101777: 3.1, 156275: 4.9, 159347: 1.0})
      
      [[54]]
      SparseVector(262144, {101777: 2.3, 156275: 4.0, 159347: 1.0})
      
      [[55]]
      SparseVector(262144, {101777: 2.8, 156275: 4.6, 159347: 1.0})
      
      [[56]]
      SparseVector(262144, {101777: 2.8, 156275: 4.5, 159347: 1.0})
      
      [[57]]
      SparseVector(262144, {101777: 3.3, 156275: 4.7, 159347: 1.0})
      
      [[58]]
      SparseVector(262144, {101777: 2.4, 156275: 3.3, 159347: 1.0})
      
      [[59]]
      SparseVector(262144, {101777: 2.9, 156275: 4.6, 159347: 1.0})
      
      [[60]]
      SparseVector(262144, {101777: 2.7, 156275: 3.9, 159347: 1.0})
      
      [[61]]
      SparseVector(262144, {101777: 2.0, 156275: 3.5, 159347: 1.0})
      
      [[62]]
      SparseVector(262144, {101777: 3.0, 156275: 4.2, 159347: 1.0})
      
      [[63]]
      SparseVector(262144, {101777: 2.2, 156275: 4.0, 159347: 1.0})
      
      [[64]]
      SparseVector(262144, {101777: 2.9, 156275: 4.7, 159347: 1.0})
      
      [[65]]
      SparseVector(262144, {101777: 2.9, 156275: 3.6, 159347: 1.0})
      
      [[66]]
      SparseVector(262144, {101777: 3.1, 156275: 4.4, 159347: 1.0})
      
      [[67]]
      SparseVector(262144, {101777: 3.0, 156275: 4.5, 159347: 1.0})
      
      [[68]]
      SparseVector(262144, {101777: 2.7, 156275: 4.1, 159347: 1.0})
      
      [[69]]
      SparseVector(262144, {101777: 2.2, 156275: 4.5, 159347: 1.0})
      
      [[70]]
      SparseVector(262144, {101777: 2.5, 156275: 3.9, 159347: 1.0})
      
      [[71]]
      SparseVector(262144, {101777: 3.2, 156275: 4.8, 159347: 1.0})
      
      [[72]]
      SparseVector(262144, {101777: 2.8, 156275: 4.0, 159347: 1.0})
      
      [[73]]
      SparseVector(262144, {101777: 2.5, 156275: 4.9, 159347: 1.0})
      
      [[74]]
      SparseVector(262144, {101777: 2.8, 156275: 4.7, 159347: 1.0})
      
      [[75]]
      SparseVector(262144, {101777: 2.9, 156275: 4.3, 159347: 1.0})
      
      [[76]]
      SparseVector(262144, {101777: 3.0, 156275: 4.4, 159347: 1.0})
      
      [[77]]
      SparseVector(262144, {101777: 2.8, 156275: 4.8, 159347: 1.0})
      
      [[78]]
      SparseVector(262144, {101777: 3.0, 156275: 5.0, 159347: 1.0})
      
      [[79]]
      SparseVector(262144, {101777: 2.9, 156275: 4.5, 159347: 1.0})
      
      [[80]]
      SparseVector(262144, {101777: 2.6, 156275: 3.5, 159347: 1.0})
      
      [[81]]
      SparseVector(262144, {101777: 2.4, 156275: 3.8, 159347: 1.0})
      
      [[82]]
      SparseVector(262144, {101777: 2.4, 156275: 3.7, 159347: 1.0})
      
      [[83]]
      SparseVector(262144, {101777: 2.7, 156275: 3.9, 159347: 1.0})
      
      [[84]]
      SparseVector(262144, {101777: 2.7, 156275: 5.1, 159347: 1.0})
      
      [[85]]
      SparseVector(262144, {101777: 3.0, 156275: 4.5, 159347: 1.0})
      
      [[86]]
      SparseVector(262144, {101777: 3.4, 156275: 4.5, 159347: 1.0})
      
      [[87]]
      SparseVector(262144, {101777: 3.1, 156275: 4.7, 159347: 1.0})
      
      [[88]]
      SparseVector(262144, {101777: 2.3, 156275: 4.4, 159347: 1.0})
      
      [[89]]
      SparseVector(262144, {101777: 3.0, 156275: 4.1, 159347: 1.0})
      
      [[90]]
      SparseVector(262144, {101777: 2.5, 156275: 4.0, 159347: 1.0})
      
      [[91]]
      SparseVector(262144, {101777: 2.6, 156275: 4.4, 159347: 1.0})
      
      [[92]]
      SparseVector(262144, {101777: 3.0, 156275: 4.6, 159347: 1.0})
      
      [[93]]
      SparseVector(262144, {101777: 2.6, 156275: 4.0, 159347: 1.0})
      
      [[94]]
      SparseVector(262144, {101777: 2.3, 156275: 3.3, 159347: 1.0})
      
      [[95]]
      SparseVector(262144, {101777: 2.7, 156275: 4.2, 159347: 1.0})
      
      [[96]]
      SparseVector(262144, {101777: 3.0, 156275: 4.2, 159347: 1.0})
      
      [[97]]
      SparseVector(262144, {101777: 2.9, 156275: 4.2, 159347: 1.0})
      
      [[98]]
      SparseVector(262144, {101777: 2.9, 156275: 4.3, 159347: 1.0})
      
      [[99]]
      SparseVector(262144, {101777: 2.5, 156275: 3.0, 159347: 1.0})
      
      [[100]]
      SparseVector(262144, {101777: 2.8, 156275: 4.1, 159347: 1.0})
      
      [[101]]
      SparseVector(262144, {64741: 1.0, 101777: 3.3, 156275: 6.0})
      
      [[102]]
      SparseVector(262144, {64741: 1.0, 101777: 2.7, 156275: 5.1})
      
      [[103]]
      SparseVector(262144, {64741: 1.0, 101777: 3.0, 156275: 5.9})
      
      [[104]]
      SparseVector(262144, {64741: 1.0, 101777: 2.9, 156275: 5.6})
      
      [[105]]
      SparseVector(262144, {64741: 1.0, 101777: 3.0, 156275: 5.8})
      
      [[106]]
      SparseVector(262144, {64741: 1.0, 101777: 3.0, 156275: 6.6})
      
      [[107]]
      SparseVector(262144, {64741: 1.0, 101777: 2.5, 156275: 4.5})
      
      [[108]]
      SparseVector(262144, {64741: 1.0, 101777: 2.9, 156275: 6.3})
      
      [[109]]
      SparseVector(262144, {64741: 1.0, 101777: 2.5, 156275: 5.8})
      
      [[110]]
      SparseVector(262144, {64741: 1.0, 101777: 3.6, 156275: 6.1})
      
      [[111]]
      SparseVector(262144, {64741: 1.0, 101777: 3.2, 156275: 5.1})
      
      [[112]]
      SparseVector(262144, {64741: 1.0, 101777: 2.7, 156275: 5.3})
      
      [[113]]
      SparseVector(262144, {64741: 1.0, 101777: 3.0, 156275: 5.5})
      
      [[114]]
      SparseVector(262144, {64741: 1.0, 101777: 2.5, 156275: 5.0})
      
      [[115]]
      SparseVector(262144, {64741: 1.0, 101777: 2.8, 156275: 5.1})
      
      [[116]]
      SparseVector(262144, {64741: 1.0, 101777: 3.2, 156275: 5.3})
      
      [[117]]
      SparseVector(262144, {64741: 1.0, 101777: 3.0, 156275: 5.5})
      
      [[118]]
      SparseVector(262144, {64741: 1.0, 101777: 3.8, 156275: 6.7})
      
      [[119]]
      SparseVector(262144, {64741: 1.0, 101777: 2.6, 156275: 6.9})
      
      [[120]]
      SparseVector(262144, {64741: 1.0, 101777: 2.2, 156275: 5.0})
      
      [[121]]
      SparseVector(262144, {64741: 1.0, 101777: 3.2, 156275: 5.7})
      
      [[122]]
      SparseVector(262144, {64741: 1.0, 101777: 2.8, 156275: 4.9})
      
      [[123]]
      SparseVector(262144, {64741: 1.0, 101777: 2.8, 156275: 6.7})
      
      [[124]]
      SparseVector(262144, {64741: 1.0, 101777: 2.7, 156275: 4.9})
      
      [[125]]
      SparseVector(262144, {64741: 1.0, 101777: 3.3, 156275: 5.7})
      
      [[126]]
      SparseVector(262144, {64741: 1.0, 101777: 3.2, 156275: 6.0})
      
      [[127]]
      SparseVector(262144, {64741: 1.0, 101777: 2.8, 156275: 4.8})
      
      [[128]]
      SparseVector(262144, {64741: 1.0, 101777: 3.0, 156275: 4.9})
      
      [[129]]
      SparseVector(262144, {64741: 1.0, 101777: 2.8, 156275: 5.6})
      
      [[130]]
      SparseVector(262144, {64741: 1.0, 101777: 3.0, 156275: 5.8})
      
      [[131]]
      SparseVector(262144, {64741: 1.0, 101777: 2.8, 156275: 6.1})
      
      [[132]]
      SparseVector(262144, {64741: 1.0, 101777: 3.8, 156275: 6.4})
      
      [[133]]
      SparseVector(262144, {64741: 1.0, 101777: 2.8, 156275: 5.6})
      
      [[134]]
      SparseVector(262144, {64741: 1.0, 101777: 2.8, 156275: 5.1})
      
      [[135]]
      SparseVector(262144, {64741: 1.0, 101777: 2.6, 156275: 5.6})
      
      [[136]]
      SparseVector(262144, {64741: 1.0, 101777: 3.0, 156275: 6.1})
      
      [[137]]
      SparseVector(262144, {64741: 1.0, 101777: 3.4, 156275: 5.6})
      
      [[138]]
      SparseVector(262144, {64741: 1.0, 101777: 3.1, 156275: 5.5})
      
      [[139]]
      SparseVector(262144, {64741: 1.0, 101777: 3.0, 156275: 4.8})
      
      [[140]]
      SparseVector(262144, {64741: 1.0, 101777: 3.1, 156275: 5.4})
      
      [[141]]
      SparseVector(262144, {64741: 1.0, 101777: 3.1, 156275: 5.6})
      
      [[142]]
      SparseVector(262144, {64741: 1.0, 101777: 3.1, 156275: 5.1})
      
      [[143]]
      SparseVector(262144, {64741: 1.0, 101777: 2.7, 156275: 5.1})
      
      [[144]]
      SparseVector(262144, {64741: 1.0, 101777: 3.2, 156275: 5.9})
      
      [[145]]
      SparseVector(262144, {64741: 1.0, 101777: 3.3, 156275: 5.7})
      
      [[146]]
      SparseVector(262144, {64741: 1.0, 101777: 3.0, 156275: 5.2})
      
      [[147]]
      SparseVector(262144, {64741: 1.0, 101777: 2.5, 156275: 5.0})
      
      [[148]]
      SparseVector(262144, {64741: 1.0, 101777: 3.0, 156275: 5.2})
      
      [[149]]
      SparseVector(262144, {64741: 1.0, 101777: 3.4, 156275: 5.4})
      
      [[150]]
      SparseVector(262144, {64741: 1.0, 101777: 3.0, 156275: 5.1})
      

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
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

---

    Code
      dplyr::pull(x)
    Output
      [[1]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[2]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[3]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[4]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[5]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[6]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[7]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[8]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[9]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[10]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[11]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[12]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[13]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[14]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[15]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[16]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[17]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[18]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[19]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[20]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[21]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[22]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[23]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[24]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[25]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[26]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[27]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[28]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[29]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[30]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[31]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[32]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[33]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[34]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[35]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[36]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[37]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[38]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[39]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[40]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[41]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[42]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[43]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[44]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[45]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[46]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[47]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[48]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[49]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[50]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[51]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[52]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[53]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[54]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[55]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[56]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[57]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[58]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[59]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[60]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[61]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[62]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[63]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[64]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[65]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[66]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[67]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[68]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[69]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[70]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[71]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[72]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[73]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[74]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[75]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[76]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[77]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[78]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[79]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[80]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[81]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[82]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[83]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[84]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[85]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[86]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[87]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[88]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[89]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[90]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[91]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[92]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[93]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[94]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[95]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[96]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[97]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[98]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[99]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[100]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[101]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[102]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[103]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[104]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[105]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[106]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[107]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[108]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[109]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[110]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[111]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[112]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[113]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[114]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[115]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[116]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[117]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[118]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[119]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[120]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[121]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[122]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[123]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[124]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[125]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[126]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[127]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[128]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[129]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[130]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[131]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[132]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[133]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[134]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[135]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[136]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[137]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[138]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[139]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[140]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[141]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[142]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[143]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[144]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[145]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[146]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[147]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[148]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[149]]
      DenseVector([0.0, 0.0, 0.0])
      
      [[150]]
      DenseVector([0.0, 0.0, 0.0])
      

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
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

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
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

---

    Code
      table(dplyr::pull(x))
    Output
      
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
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

---

    Code
      dplyr::pull(x)
    Output
      [[1]]
      DenseVector([55.02])
      
      [[2]]
      DenseVector([60.375])
      
      [[3]]
      DenseVector([52.896])
      
      [[4]]
      DenseVector([68.801])
      
      [[5]]
      DenseVector([64.328])
      
      [[6]]
      DenseVector([62.626])
      
      [[7]]
      DenseVector([51.051])
      
      [[8]]
      DenseVector([77.836])
      
      [[9]]
      DenseVector([71.82])
      
      [[10]]
      DenseVector([66.048])
      
      [[11]]
      DenseVector([61.232])
      
      [[12]]
      DenseVector([66.748])
      
      [[13]]
      DenseVector([64.529])
      
      [[14]]
      DenseVector([57.456])
      
      [[15]]
      DenseVector([54.6])
      
      [[16]]
      DenseVector([56.4096])
      
      [[17]]
      DenseVector([78.5715])
      
      [[18]]
      DenseVector([71.28])
      
      [[19]]
      DenseVector([49.096])
      
      [[20]]
      DenseVector([62.2065])
      
      [[21]]
      DenseVector([52.9975])
      
      [[22]]
      DenseVector([54.56])
      
      [[23]]
      DenseVector([52.212])
      
      [[24]]
      DenseVector([51.072])
      
      [[25]]
      DenseVector([73.824])
      
      [[26]]
      DenseVector([52.8255])
      
      [[27]]
      DenseVector([55.64])
      
      [[28]]
      DenseVector([45.9952])
      
      [[29]]
      DenseVector([50.086])
      
      [[30]]
      DenseVector([54.569])
      
      [[31]]
      DenseVector([53.55])
      
      [[32]]
      DenseVector([59.492])
      

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
      ft_r_formula(use_test_table_mtcars(), mpg ~ ., features_col = "test") %>%
        colnames()
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
      class(x)
    Output
      [1] "tbl_pyspark" "tbl_spark"   "tbl_sql"     "tbl_lazy"    "tbl"        

---

    Code
      dplyr::pull(x)
    Output
      [[1]]
      DenseVector([5.1, 3.5, 1.4])
      
      [[2]]
      DenseVector([4.9, 3.0, 1.4])
      
      [[3]]
      DenseVector([4.7, 3.2, 1.3])
      
      [[4]]
      DenseVector([4.6, 3.1, 1.5])
      
      [[5]]
      DenseVector([5.0, 3.6, 1.4])
      
      [[6]]
      DenseVector([5.4, 3.9, 1.7])
      
      [[7]]
      DenseVector([4.6, 3.4, 1.4])
      
      [[8]]
      DenseVector([5.0, 3.4, 1.5])
      
      [[9]]
      DenseVector([4.4, 2.9, 1.4])
      
      [[10]]
      DenseVector([4.9, 3.1, 1.5])
      
      [[11]]
      DenseVector([5.4, 3.7, 1.5])
      
      [[12]]
      DenseVector([4.8, 3.4, 1.6])
      
      [[13]]
      DenseVector([4.8, 3.0, 1.4])
      
      [[14]]
      DenseVector([4.3, 3.0, 1.1])
      
      [[15]]
      DenseVector([5.8, 4.0, 1.2])
      
      [[16]]
      DenseVector([5.7, 4.4, 1.5])
      
      [[17]]
      DenseVector([5.4, 3.9, 1.3])
      
      [[18]]
      DenseVector([5.1, 3.5, 1.4])
      
      [[19]]
      DenseVector([5.7, 3.8, 1.7])
      
      [[20]]
      DenseVector([5.1, 3.8, 1.5])
      
      [[21]]
      DenseVector([5.4, 3.4, 1.7])
      
      [[22]]
      DenseVector([5.1, 3.7, 1.5])
      
      [[23]]
      DenseVector([4.6, 3.6, 1.0])
      
      [[24]]
      DenseVector([5.1, 3.3, 1.7])
      
      [[25]]
      DenseVector([4.8, 3.4, 1.9])
      
      [[26]]
      DenseVector([5.0, 3.0, 1.6])
      
      [[27]]
      DenseVector([5.0, 3.4, 1.6])
      
      [[28]]
      DenseVector([5.2, 3.5, 1.5])
      
      [[29]]
      DenseVector([5.2, 3.4, 1.4])
      
      [[30]]
      DenseVector([4.7, 3.2, 1.6])
      
      [[31]]
      DenseVector([4.8, 3.1, 1.6])
      
      [[32]]
      DenseVector([5.4, 3.4, 1.5])
      
      [[33]]
      DenseVector([5.2, 4.1, 1.5])
      
      [[34]]
      DenseVector([5.5, 4.2, 1.4])
      
      [[35]]
      DenseVector([4.9, 3.1, 1.5])
      
      [[36]]
      DenseVector([5.0, 3.2, 1.2])
      
      [[37]]
      DenseVector([5.5, 3.5, 1.3])
      
      [[38]]
      DenseVector([4.9, 3.6, 1.4])
      
      [[39]]
      DenseVector([4.4, 3.0, 1.3])
      
      [[40]]
      DenseVector([5.1, 3.4, 1.5])
      
      [[41]]
      DenseVector([5.0, 3.5, 1.3])
      
      [[42]]
      DenseVector([4.5, 2.3, 1.3])
      
      [[43]]
      DenseVector([4.4, 3.2, 1.3])
      
      [[44]]
      DenseVector([5.0, 3.5, 1.6])
      
      [[45]]
      DenseVector([5.1, 3.8, 1.9])
      
      [[46]]
      DenseVector([4.8, 3.0, 1.4])
      
      [[47]]
      DenseVector([5.1, 3.8, 1.6])
      
      [[48]]
      DenseVector([4.6, 3.2, 1.4])
      
      [[49]]
      DenseVector([5.3, 3.7, 1.5])
      
      [[50]]
      DenseVector([5.0, 3.3, 1.4])
      
      [[51]]
      DenseVector([7.0, 3.2, 4.7])
      
      [[52]]
      DenseVector([6.4, 3.2, 4.5])
      
      [[53]]
      DenseVector([6.9, 3.1, 4.9])
      
      [[54]]
      DenseVector([5.5, 2.3, 4.0])
      
      [[55]]
      DenseVector([6.5, 2.8, 4.6])
      
      [[56]]
      DenseVector([5.7, 2.8, 4.5])
      
      [[57]]
      DenseVector([6.3, 3.3, 4.7])
      
      [[58]]
      DenseVector([4.9, 2.4, 3.3])
      
      [[59]]
      DenseVector([6.6, 2.9, 4.6])
      
      [[60]]
      DenseVector([5.2, 2.7, 3.9])
      
      [[61]]
      DenseVector([5.0, 2.0, 3.5])
      
      [[62]]
      DenseVector([5.9, 3.0, 4.2])
      
      [[63]]
      DenseVector([6.0, 2.2, 4.0])
      
      [[64]]
      DenseVector([6.1, 2.9, 4.7])
      
      [[65]]
      DenseVector([5.6, 2.9, 3.6])
      
      [[66]]
      DenseVector([6.7, 3.1, 4.4])
      
      [[67]]
      DenseVector([5.6, 3.0, 4.5])
      
      [[68]]
      DenseVector([5.8, 2.7, 4.1])
      
      [[69]]
      DenseVector([6.2, 2.2, 4.5])
      
      [[70]]
      DenseVector([5.6, 2.5, 3.9])
      
      [[71]]
      DenseVector([5.9, 3.2, 4.8])
      
      [[72]]
      DenseVector([6.1, 2.8, 4.0])
      
      [[73]]
      DenseVector([6.3, 2.5, 4.9])
      
      [[74]]
      DenseVector([6.1, 2.8, 4.7])
      
      [[75]]
      DenseVector([6.4, 2.9, 4.3])
      
      [[76]]
      DenseVector([6.6, 3.0, 4.4])
      
      [[77]]
      DenseVector([6.8, 2.8, 4.8])
      
      [[78]]
      DenseVector([6.7, 3.0, 5.0])
      
      [[79]]
      DenseVector([6.0, 2.9, 4.5])
      
      [[80]]
      DenseVector([5.7, 2.6, 3.5])
      
      [[81]]
      DenseVector([5.5, 2.4, 3.8])
      
      [[82]]
      DenseVector([5.5, 2.4, 3.7])
      
      [[83]]
      DenseVector([5.8, 2.7, 3.9])
      
      [[84]]
      DenseVector([6.0, 2.7, 5.1])
      
      [[85]]
      DenseVector([5.4, 3.0, 4.5])
      
      [[86]]
      DenseVector([6.0, 3.4, 4.5])
      
      [[87]]
      DenseVector([6.7, 3.1, 4.7])
      
      [[88]]
      DenseVector([6.3, 2.3, 4.4])
      
      [[89]]
      DenseVector([5.6, 3.0, 4.1])
      
      [[90]]
      DenseVector([5.5, 2.5, 4.0])
      
      [[91]]
      DenseVector([5.5, 2.6, 4.4])
      
      [[92]]
      DenseVector([6.1, 3.0, 4.6])
      
      [[93]]
      DenseVector([5.8, 2.6, 4.0])
      
      [[94]]
      DenseVector([5.0, 2.3, 3.3])
      
      [[95]]
      DenseVector([5.6, 2.7, 4.2])
      
      [[96]]
      DenseVector([5.7, 3.0, 4.2])
      
      [[97]]
      DenseVector([5.7, 2.9, 4.2])
      
      [[98]]
      DenseVector([6.2, 2.9, 4.3])
      
      [[99]]
      DenseVector([5.1, 2.5, 3.0])
      
      [[100]]
      DenseVector([5.7, 2.8, 4.1])
      
      [[101]]
      DenseVector([6.3, 3.3, 6.0])
      
      [[102]]
      DenseVector([5.8, 2.7, 5.1])
      
      [[103]]
      DenseVector([7.1, 3.0, 5.9])
      
      [[104]]
      DenseVector([6.3, 2.9, 5.6])
      
      [[105]]
      DenseVector([6.5, 3.0, 5.8])
      
      [[106]]
      DenseVector([7.6, 3.0, 6.6])
      
      [[107]]
      DenseVector([4.9, 2.5, 4.5])
      
      [[108]]
      DenseVector([7.3, 2.9, 6.3])
      
      [[109]]
      DenseVector([6.7, 2.5, 5.8])
      
      [[110]]
      DenseVector([7.2, 3.6, 6.1])
      
      [[111]]
      DenseVector([6.5, 3.2, 5.1])
      
      [[112]]
      DenseVector([6.4, 2.7, 5.3])
      
      [[113]]
      DenseVector([6.8, 3.0, 5.5])
      
      [[114]]
      DenseVector([5.7, 2.5, 5.0])
      
      [[115]]
      DenseVector([5.8, 2.8, 5.1])
      
      [[116]]
      DenseVector([6.4, 3.2, 5.3])
      
      [[117]]
      DenseVector([6.5, 3.0, 5.5])
      
      [[118]]
      DenseVector([7.7, 3.8, 6.7])
      
      [[119]]
      DenseVector([7.7, 2.6, 6.9])
      
      [[120]]
      DenseVector([6.0, 2.2, 5.0])
      
      [[121]]
      DenseVector([6.9, 3.2, 5.7])
      
      [[122]]
      DenseVector([5.6, 2.8, 4.9])
      
      [[123]]
      DenseVector([7.7, 2.8, 6.7])
      
      [[124]]
      DenseVector([6.3, 2.7, 4.9])
      
      [[125]]
      DenseVector([6.7, 3.3, 5.7])
      
      [[126]]
      DenseVector([7.2, 3.2, 6.0])
      
      [[127]]
      DenseVector([6.2, 2.8, 4.8])
      
      [[128]]
      DenseVector([6.1, 3.0, 4.9])
      
      [[129]]
      DenseVector([6.4, 2.8, 5.6])
      
      [[130]]
      DenseVector([7.2, 3.0, 5.8])
      
      [[131]]
      DenseVector([7.4, 2.8, 6.1])
      
      [[132]]
      DenseVector([7.9, 3.8, 6.4])
      
      [[133]]
      DenseVector([6.4, 2.8, 5.6])
      
      [[134]]
      DenseVector([6.3, 2.8, 5.1])
      
      [[135]]
      DenseVector([6.1, 2.6, 5.6])
      
      [[136]]
      DenseVector([7.7, 3.0, 6.1])
      
      [[137]]
      DenseVector([6.3, 3.4, 5.6])
      
      [[138]]
      DenseVector([6.4, 3.1, 5.5])
      
      [[139]]
      DenseVector([6.0, 3.0, 4.8])
      
      [[140]]
      DenseVector([6.9, 3.1, 5.4])
      
      [[141]]
      DenseVector([6.7, 3.1, 5.6])
      
      [[142]]
      DenseVector([6.9, 3.1, 5.1])
      
      [[143]]
      DenseVector([5.8, 2.7, 5.1])
      
      [[144]]
      DenseVector([6.8, 3.2, 5.9])
      
      [[145]]
      DenseVector([6.7, 3.3, 5.7])
      
      [[146]]
      DenseVector([6.7, 3.0, 5.2])
      
      [[147]]
      DenseVector([6.3, 2.5, 5.0])
      
      [[148]]
      DenseVector([6.5, 3.0, 5.2])
      
      [[149]]
      DenseVector([6.2, 3.4, 5.4])
      
      [[150]]
      DenseVector([5.9, 3.0, 5.1])
      

