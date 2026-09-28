# Functions work

    Code
      colnames(transform_impl(model, tbl_mtcars, prep = TRUE))
    Output
       [1] "mpg"           "cyl"           "disp"          "hp"           
       [5] "drat"          "wt"            "qsec"          "vs"           
       [9] "am"            "gear"          "carb"          "features"     
      [13] "rawPrediction" "probability"   "prediction"   

---

    Code
      colnames(transform_impl(model, tbl_mtcars, prep = TRUE, remove = TRUE))
    Output
       [1] "mpg"           "cyl"           "disp"          "hp"           
       [5] "drat"          "wt"            "qsec"          "vs"           
       [9] "am"            "gear"          "carb"          "rawPrediction"
      [13] "probability"   "prediction"   

