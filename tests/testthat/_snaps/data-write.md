# CSV works

    Code
      spark_read_csv(sc, "csv_1", file_name, overwrite = TRUE)
    Output
      # Source: spark<csv_1> [?? x 11]
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
      # i more rows

# Parquet works

    Code
      spark_read_parquet(sc, "csv_1", file_name, overwrite = TRUE)
    Output
      # Source: spark<csv_1> [?? x 11]
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
      # i more rows

# ORC works

    Code
      spark_read_orc(sc, "csv_1", file_name, overwrite = TRUE)
    Output
      # Source: spark<csv_1> [?? x 11]
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
      # i more rows

# JSON works

    Code
      spark_read_json(sc, "csv_1", file_name, overwrite = TRUE)
    Output
      # Source: spark<csv_1> [?? x 11]
            am  carb   cyl  disp  drat  gear    hp   mpg  qsec    vs    wt
         <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
       1     1     4     6  160   3.9      4   110  21    16.5     0  2.62
       2     1     4     6  160   3.9      4   110  21    17.0     0  2.88
       3     1     1     4  108   3.85     4    93  22.8  18.6     1  2.32
       4     0     1     6  258   3.08     3   110  21.4  19.4     1  3.22
       5     0     2     8  360   3.15     3   175  18.7  17.0     0  3.44
       6     0     1     6  225   2.76     3   105  18.1  20.2     1  3.46
       7     0     4     8  360   3.21     3   245  14.3  15.8     0  3.57
       8     0     2     4  147.  3.69     4    62  24.4  20       1  3.19
       9     0     2     4  141.  3.92     4    95  22.8  22.9     1  3.15
      10     0     4     6  168.  3.92     4   123  19.2  18.3     1  3.44
      # i more rows

