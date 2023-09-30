# Pivot longer

    Code
      tbl_pivot %>% pivot_longer(x:y)
    Output
      # Source: spark<?> [?? x 2]
        name  value
        <chr> <int>
      1 x         1
      2 y         3
      3 x         2
      4 y         4

