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
    collected <- try(
      {
        as.data.frame(pandas_tbl$values) |>
          lapply(\(col) {
            map_vec(
              col,
              \(x) {
                if (length(x) == 0 || is.nan(x)) {
                  NA
                } else {
                  x[[1]]
                }
              }
            )
          }) |>
          set_names(x$columns)
      },
      silent = TRUE
    )
    if (inherits(collected, "try-error")) {
      collected <- x$toArrow()
      collected <- collected$to_data_frame()
    }
  }

  # Handle NULL columns by converting them to appropriate empty vectors
  for (i in seq_along(collected)) {
    if (is.null(collected[[i]])) {
      collected[[i]] <- character(0)
    }
    # Convert arrow_binary to list
    if (inherits(collected[[i]], "arrow_binary")) {
      collected[[i]] <- as.list(collected[[i]])
    }
    # Convert UTC timestamps to local timezone
    if (inherits(collected[[i]], "POSIXct")) {
      # If the timestamp is in UTC, convert to local timezone
      if (!is.null(attr(collected[[i]], "tzone")) && attr(collected[[i]], "tzone") == "UTC") {
        attr(collected[[i]], "tzone") <- ""
      }
    }
    # Convert pandas Arrow-backed arrays to regular R vectors
    if (inherits(collected[[i]], "python.builtin.object")) {
      col_class <- try(class(collected[[i]]), silent = TRUE)
      if (!inherits(col_class, "try-error")) {
        # Check if it's an Arrow-backed array from pandas
        if (any(grepl("ArrowStringArray|ArrowExtensionArray", col_class))) {
          # Convert to regular character vector using numpy
          collected[[i]] <- try(
            as.character(collected[[i]]$to_numpy()),
            silent = TRUE
          )
          # Fallback to Python list conversion if to_numpy fails
          if (inherits(collected[[i]], "try-error")) {
            collected[[i]] <- as.character(collected[[i]]$tolist())
          }
        }
      }
    }
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
      } else if (py_type == "date" && r_type %in% c("numeric", "integer", "logical")) {
        as.Date(col, origin = "1970-01-01")
      } else if (py_type == "boolean" && r_type == "list") {
        map_lgl(col, clean_col)
      } else if (py_type == "boolean" && r_type == "character") {
        as.logical(col)
      } else if (r_type == "integer" && py_type %in% c("bigint", "long")) {
        # Convert bigint/long to numeric since R integer is 32-bit
        as.numeric(col)
      } else if (r_type == "numeric" || r_type == "integer") {
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
