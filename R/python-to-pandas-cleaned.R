to_pandas_cleaned <- function(x) {
  fields <- x$dtypes
  orig_types <- map_chr(fields, \(.x) .x[[2]])

  dec_types <- map_lgl(orig_types, \(.x) grepl("decimal\\(", .x))

  if (sum(dec_types) > 0) {
    # Has to check if SQL functions can be imported because some backend
    # connection Python packages does not include it
    sf <- try(import("pyspark.sql.functions"), silent = TRUE)
    if (!inherits(sf, "try-error")) {
      for (field in fields[dec_types]) {
        fn <- field[[1]]
        x <- x$withColumn(fn, sf$col(fn)$cast("double"))
      }
    }
  }

  pandas_tbl <- x$toPandas()

  if(is.data.frame(pandas_tbl)) {
    collected <- pandas_tbl
  } else {
    # Pandas 3.0 conversion makes encases all columns inside lists
    collected <- pandas_tbl$values |>
      as.data.frame() |>
      lapply(unlist) |>
      set_names(x$columns)
  }

  collected <- collected |>
    dplyr::as_tibble()

  col_types <- map_chr(
    collected, \(.x) {
      classes <- class(.x)
      classes[[1]]
    }
  )

  extract_list <- function(x) if (length(x)==0 || is.nan(x)) NA else x[[1]]

  for (i in seq_len(ncol(collected))) {

    ot <- orig_types[i]
    ct <- col_types[i]
    col <- collected[[i]]

    collected[[i]] <-
      if (ot == "date" && ct == "list") {
        as.Date(map_vec(col, extract_list), origin="1970-01-01")
      } else if (ot == "date" && ct == "character") {
        as.Date(col, origin="1970-01-01")
      } else if (ot == "boolean" && ct == "list") {
        map_lgl(col, extract_list)
      } else if (ot == "boolean" && ct == "character") {
        as.logical(col)
      } else if (ot == "int" && ct == "numeric") {
        map_int(col, ~ ifelse(length(.x)==0 || is.nan(.x), NA, .x))
      } else if (ct == "numeric") {
        map_dbl(col, ~ ifelse(length(.x)==0 || is.nan(.x), NA, .x))
      } else {
        col
      }
  }

  out <- tibble(collected)

  # Snowflake returns field names in double quotes
  colnames(out) <- gsub("\"", "", colnames(out))

  attr(out, "pandas.index") <- NULL
  out
}
