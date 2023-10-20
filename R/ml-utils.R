ml_formula <- function(f, data) {
  col_data <- colnames(data)

  temp_tbl <- rep(1, times = length(col_data)) %>%
    purrr::set_names(col_data) %>%
    as.list() %>%
    as.data.frame()

  f_terms <- terms(f, data = temp_tbl)

  f_factors <- attr(f_terms, "factors")

  feat_names <- colnames(f_factors)
  row_f <- rownames(f_factors)

  for (i in feat_names) {
    in_data <- i %in% col_data
    if (!in_data) {
      cli_abort(c(
        "Formula resulted in an invalid parameter set\n",
        "- Only '+' is supported."
      ), call = NULL)
    }
  }

  label <- NULL
  for (i in row_f) {
    if (!(i %in% feat_names)) {
      label <- c(label, i)
    }
  }
  list(
    label = label,
    features = feat_names
  )
}

snake_to_camel <- function(x) {
  s <- unlist(strsplit(x, "_"))
  x <- paste(
    toupper(substring(s, 1, 1)), substring(s, 2),
    sep = "", collapse = ""
  )
  paste(
    tolower(substring(x, 1, 1)), substring(x, 2),
    sep = "", collapse = ""
  )
}

ml_connect_not_supported <- function(args, not_supported = c()) {
  x <- map_chr(
    not_supported,
    ~ {
      if (.x %in% names(args)) {
        arg <- args[names(args) == .x]
        if (!is.null(arg[[1]])) {
          ret <- paste0("{.emph - `", names(arg), "`}")
        } else {
          ret <- ""
        }
      }
    }
  )

  x <- x[x != ""]

  if (length(x) > 0) {
    cli_abort(c(
      "The following argument(s) are not supported by Spark Connect:",
      x,
      "Set it(them) to `NULL` and try again."
    ))
  }
}
