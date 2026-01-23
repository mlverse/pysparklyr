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

  if (is.data.frame(pandas_tbl)) {
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
    collected,
    \(.x) {
      classes <- class(.x)
      classes[[1]]
    }
  )

  clean_col <- function(x, subset = TRUE) {
    if (length(x) == 0 || is.nan(x)) {
      x <- NA
    } else if (subset) {
      x <- x[[1]]
    }
    x
  }

  for (i in seq_len(ncol(collected))) {
    py_type <- orig_types[i]
    r_type <- col_types[i]
    col <- collected[[i]]
    collected[[i]] <-
      if (py_type == "date" && r_type == "list") {
        as.Date(map_vec(col, clean_col), origin = "1970-01-01")
      } else if (py_type == "date" && r_type == "character") {
        as.Date(col, origin = "1970-01-01")
      } else if (py_type == "boolean" && r_type == "list") {
        map_lgl(col, clean_col)
      } else if (py_type == "boolean" && r_type == "character") {
        as.logical(col)
      } else if (r_type == "numeric") {
        if (py_type %in% c("tinyint", "smallint", "int")) {
          ptype <- integer()
        } else {
          ptype <- numeric()
        }
        map_vec(col, clean_col, FALSE, .ptype = ptype)
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
