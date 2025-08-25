# R Formula works with Spark Connection

    Code
      class(ft_r_formula(sc))
    Output
      [1] "ml_transformer"    "ml_pipeline_stage"

# R Formula works with Pipeline

    Code
      cap_out[c(1, 3:4)]
    Output
      [1] "Pipeline (Estimator) with 1 stage" "  Stages "                        
      [3] "  |--1 RFormula (JavaParams)"     

