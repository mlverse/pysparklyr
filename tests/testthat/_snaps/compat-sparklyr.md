# Internal functions work

    Code
      .strsep("domino", 3)
    Output
      [[1]]
      [1] "dom"
      
      [[2]]
      [1] "ino"
      

---

    Code
      .str_split_n("hello", "l", n_max = 3)
    Output
      [[1]]
      [1] "he" ""   "o" 
      

---

    Code
      .list_indices(c("one", "two", "three"), 2)
    Output
      [1] "one, two, ..."

---

    Code
      .simplify_pieces(c("one", "two", "three"), 2, FALSE)
    Output
      $strings
      $strings[[1]]
      [1] NA NA NA
      
      $strings[[2]]
      [1] NA NA NA
      
      
      $too_big
      NULL
      
      $too_sml
      [1] 1 2 3
      

