# Functions work

    Code
      colnames(transform_impl(model, tbl_mtcars, prep = TRUE))
    Output
       [1] "mpg"         "cyl"         "disp"        "hp"          "drat"       
       [6] "wt"          "qsec"        "vs"          "am"          "gear"       
      [11] "carb"        "features"    "prediction"  "probability"

---

    Code
      colnames(transform_impl(model, tbl_mtcars, prep = TRUE, remove = TRUE))
    Output
       [1] "mpg"         "cyl"         "disp"        "hp"          "drat"       
       [6] "wt"          "qsec"        "vs"          "am"          "gear"       
      [11] "carb"        "prediction"  "probability"

