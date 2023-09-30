# Object retrieval function work

    Code
      spark_ide_columns(sc, table = "mtcars")
    Output
           name                               type
      mpg   mpg      num 21 21 22.8 21.4 18.7 18.1
      cyl   cyl                    num 6 6 4 6 8 6
      disp disp        num 160 160 108 258 360 225
      hp     hp         num 110 110 93 110 175 105
      drat drat    num 3.9 3.9 3.85 3.08 3.15 2.76
      wt     wt num 2.62 2.875 2.32 3.215 3.44 ...
      qsec qsec num 16.46 17.02 18.61 19.44 17....
      vs     vs                    num 0 0 1 1 0 1
      am     am                    num 1 1 1 0 0 0
      gear gear                    num 4 4 4 3 3 3
      carb carb                    num 4 4 1 1 2 1

---

    Code
      spark_ide_preview(sc, table = "mtcars", rowLimit = 10)
    Output
      # A tibble: 10 x 11
           mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
         <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
       1  21       6  160    110  3.9   2.62  16.5     0     1     4     4
       2  21       6  160    110  3.9   2.88  17.0     0     1     4     4
       3  22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
       4  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
       5  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
       6  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
       7  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
       8  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
       9  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
      10  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4

