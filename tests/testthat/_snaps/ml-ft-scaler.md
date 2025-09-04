# Standard Scaler works with Spark Connection

    Code
      class(ft_standard_scaler(sc))
    Output
      [1] "ft_standard_scaler" "ml_transformer"     "ml_pipeline_stage" 

# Standard Scaler works with Pipeline

    Code
      cap_out[c(1, 3:4)]
    Output
      [1] "Pipeline (Estimator) with 1 stage"  "  Stages "                         
      [3] "  |--1 StandardScaler (JavaParams)"

