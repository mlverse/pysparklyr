to_pandas_cleaned <- function(x) {
  fields <- x$dtypes
  orig_types <- map_chr(fields, ~ .x[[2]])

  dec_types <- map_lgl(orig_types, ~ grepl("decimal\\(", .x))

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

  collected <- dplyr::as_tibble(x$toPandas())
  col_types <- map_chr(
    collected, ~ {
      classes <- class(.x)
      classes[[1]]
    }
  )

  for (i in seq_len(ncol(collected))) {
    if (orig_types[i] == "date") {
      to_date <- collected[, i] %>%
        as.integer() %>%
        as.Date(origin = "1970-01-01")
      collected[, i] <- to_date
    }
  }

  out <- tibble(collected)

  # Snowflake returns field names in double quotes
  colnames(out) <- gsub("\"", "", colnames(out))

  attr(out, "pandas.index") <- NULL
  out
}
