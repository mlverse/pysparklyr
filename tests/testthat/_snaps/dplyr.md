# copy_to() works

    Code
      tbl_ordered
    Output
      # Source:     spark<?> [?? x 11]
      # Ordered by: mpg, qsec, hp
           mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
         <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
       1  10.4     8  460    215  3     5.42  17.8     0     0     3     4
       2  10.4     8  472    205  2.93  5.25  18.0     0     0     3     4
       3  13.3     8  350    245  3.73  3.84  15.4     0     0     3     4
       4  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
       5  14.7     8  440    230  3.23  5.34  17.4     0     0     3     4
       6  15       8  301    335  3.54  3.57  14.6     0     1     5     8
       7  15.2     8  304    150  3.15  3.44  17.3     0     0     3     2
       8  15.2     8  276.   180  3.07  3.78  18       0     0     3     3
       9  15.5     8  318    150  2.76  3.52  16.9     0     0     3     2
      10  15.8     8  351    264  4.22  3.17  14.5     0     1     5     4
      # i more rows

---

    Code
      print(head(tbl_ordered))
    Output
      # Source:     spark<?> [?? x 11]
      # Ordered by: mpg, qsec, hp
          mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
        <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
      1  10.4     8   460   215  3     5.42  17.8     0     0     3     4
      2  10.4     8   472   205  2.93  5.25  18.0     0     0     3     4
      3  13.3     8   350   245  3.73  3.84  15.4     0     0     3     4
      4  14.3     8   360   245  3.21  3.57  15.8     0     0     3     4
      5  14.7     8   440   230  3.23  5.34  17.4     0     0     3     4
      6  15       8   301   335  3.54  3.57  14.6     0     1     5     8

# Misc functions

    Code
      tbl_join
    Output
      # Source:     spark<?> [?? x 11]
      # Ordered by: mpg, qsec, hp
           mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
         <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
       1  10.4     8  460    215  3     5.42  17.8     0     0     3     4
       2  10.4     8  472    205  2.93  5.25  18.0     0     0     3     4
       3  13.3     8  350    245  3.73  3.84  15.4     0     0     3     4
       4  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
       5  14.7     8  440    230  3.23  5.34  17.4     0     0     3     4
       6  15       8  301    335  3.54  3.57  14.6     0     1     5     8
       7  15.2     8  304    150  3.15  3.44  17.3     0     0     3     2
       8  15.2     8  276.   180  3.07  3.78  18       0     0     3     3
       9  15.5     8  318    150  2.76  3.52  16.9     0     0     3     2
      10  15.8     8  351    264  4.22  3.17  14.5     0     1     5     4
      # i more rows

