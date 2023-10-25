# Standard Scaler works with Spark Connection

    Code
      class(ft_standard_scaler(sc))
    Output
      [1] "ml_connect_estimator" "ml_estimator"         "ml_pipeline_stage"   

# Standard Scaler works with `tbl_spark`

    Code
      colnames(scale)
    Output
       [1] "mpg"             "cyl"             "disp"            "hp"             
       [5] "drat"            "wt"              "qsec"            "vs"             
       [9] "am"              "gear"            "carb"            "scaled_features"

# Standard Scaler works with Pipeline

    Code
      cap_out[c(1, 3:4)]
    Output
      [1] "Pipeline (Estimator) with 1 stage"   "  Stages "                          
      [3] "  |--1 StandardScaler (HasInputCol)"

# Max Abs Scaler works with Spark Connection

    Code
      class(ft_max_abs_scaler(sc))
    Output
      [1] "ml_connect_estimator" "ml_estimator"         "ml_pipeline_stage"   

# Max Abs Scaler works with `tbl_spark`

    Code
      colnames(scale)
    Output
       [1] "mpg"             "cyl"             "disp"            "hp"             
       [5] "drat"            "wt"              "qsec"            "vs"             
       [9] "am"              "gear"            "carb"            "scaled_features"

# Max Abs Scaler works with Pipeline

    Code
      cap_out[c(1, 3:4)]
    Output
      [1] "Pipeline (Estimator) with 1 stage" "  Stages "                        
      [3] "  |--1 MaxAbsScaler (HasInputCol)"

# Print method works

    Code
      ft_standard_scaler(sc)
    Message <rlang_message>
      <StandardScaler>

