# Pivot longer

    Code
      tbl_pivot %>% tidyr::pivot_longer(-id, names_to = c(".value", "n"), names_sep = "_")
    Output
      # Source:   table<sparklyr_tmp_table_60b5433c_d4da_42a5_86cd_2a2fffdc57b2> [4 x 5]
      # Database: spark_connection
        id    n         z     y     x
        <chr> <chr> <dbl> <dbl> <dbl>
      1 A     1         1     2     3
      2 A     2         4     5     6
      3 B     1         7     8     9
      4 B     2        10    11    12

