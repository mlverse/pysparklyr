to_pandas_cleaned <- function(x) {
  fields <- x$dtypes
  orig_types <- map_chr(fields, ~ .x[[2]])

  dec_types <- map_lgl(orig_types, ~ grepl("decimal\\(", .x))

  if (sum(dec_types) > 0) {
    sf <- import("pyspark.sql.functions")
    for (field in fields[dec_types]) {
      fn <- field[[1]]
      x <- x$withColumn(fn, sf$col(fn)$cast("double"))
    }
  }

  collected <- x$toPandas()
  col_types <- map_chr(
    collected, ~ {
      classes <- class(.x)
      classes[[1]]
    }
  )

  list_types <- col_types == "list"
  list_vars <- col_types[list_types]
  orig_vars <- orig_types[list_types]

  for (i in seq_along(list_vars)) {
    if (orig_vars[[i]] != "array") {
      cur_var <- names(list_vars[i])
      cur <- collected[[cur_var]]
      cur_null <- map_lgl(cur, is.null)
      cur <- as.character(cur)
      cur[cur_null] <- NA
      collected[[cur_var]] <- cur
    }
  }

  for (i in seq_len(ncol(collected))) {
    if (orig_types[i] == "date") {
      to_date <- collected[, i] %>%
        as.integer() %>%
        as.Date(origin = "1970-01-01")
      collected[, i] <- to_date
    }
  }

  out <- tibble(collected)

  attr(out, "pandas.index") <- NULL
  out
}
