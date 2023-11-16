# ---------------------------- tidyr pivot_longer ------------------------------
.strsep <- function(x, sep) {
  nchar <- nchar(x)
  pos <- map(sep, function(i) {
    if (i >= 0) {
      return(i)
    }
    pmax(0, nchar + i)
  })
  pos <- c(list(0), pos, list(nchar))

  map(seq_len(length(pos) - 1), function(i) {
    substr(x, pos[[i]] + 1, pos[[i + 1]])
  })
}

.slice_match <- function(x, i) {
  structure(
    x[i],
    match.length = attr(x, "match.length")[i],
    index.type = attr(x, "index.type"),
    useBytes = attr(x, "useBytes")
  )
}

.str_split_n <- function(x, pattern, n_max = -1) {
  m <- gregexpr(pattern, x, perl = TRUE)
  if (n_max > 0) {
    m <- lapply(m, function(x) .slice_match(x, seq_along(x) < n_max))
  }
  regmatches(x, m, invert = TRUE)
}

.list_indices <- function(x, max = 20) {
  if (length(x) > max) {
    x <- c(x[seq_len(max)], "...")
  }

  paste(x, collapse = ", ")
}

.simplify_pieces <- function(pieces, p, fill_left) {
  too_sml <- NULL
  too_big <- NULL
  n <- length(pieces)

  out <- lapply(seq(p), function(x) rep(NA, n))
  for (i in seq_along(pieces)) {
    x <- pieces[[i]]
    if (!(length(x) == 1 && is.na(x[[1]]))) {
      if (length(x) > p) {
        too_big <- c(too_big, i)

        for (j in seq(p)) {
          out[[j]][[i]] <- x[[j]]
        }
      } else if (length(x) < p) {
        too_sml <- c(too_sml, i)

        gap <- p - length(x)
        for (j in seq(p)) {
          if (fill_left) {
            out[[j]][[i]] <- (
              if (j >= gap) x[[j - gap]] else NA
            )
          } else {
            out[[j]][[i]] <- (
              if (j < length(x)) x[[j]] else NA
            )
          }
        }
      } else {
        for (j in seq(p)) {
          out[[j]][[i]] <- x[[j]]
        }
      }
    }
  }

  structure(list(
    strings = out,
    too_big = too_big,
    too_sml = too_sml
  ))
}

.str_split_fixed <- function(value, sep, n, extra = "warn", fill = "warn") {
  if (extra == "error") {
    warn(glue(
      "`extra = \"error\"` is deprecated. \\
       Please use `extra = \"warn\"` instead"
    ))
    extra <- "warn"
  }

  extra <- arg_match(extra, c("warn", "merge", "drop"))
  fill <- arg_match(fill, c("warn", "left", "right"))

  n_max <- if (extra == "merge") n else -1L
  pieces <- .str_split_n(value, sep, n_max = n_max)

  simp <- .simplify_pieces(pieces, n, fill == "left")

  n_big <- length(simp$too_big)
  if (extra == "warn" && n_big > 0) {
    idx <- .list_indices(simp$too_big)
    warn(glue(
      "Expected {n} pieces. ",
      "Additional pieces discarded in {n_big} rows [{idx}]."
    ))
  }

  n_sml <- length(simp$too_sml)
  if (fill == "warn" && n_sml > 0) {
    idx <- .list_indices(simp$too_sml)
    warn(glue(
      "Expected {n} pieces. ",
      "Missing pieces filled with `NA` in {n_sml} rows [{idx}]."
    ))
  }

  simp$strings
}

.str_separate <- function(x, into, sep, extra = "warn", fill = "warn") {
  if (!is.character(into)) {
    abort("`into` must be a character vector")
  }

  if (is.numeric(sep)) {
    out <- .strsep(x, sep)
  } else if (is_character(sep)) {
    out <- .str_split_fixed(x, sep, length(into), extra = extra, fill = fill)
  } else {
    abort("`sep` must be either numeric or character")
  }

  names(out) <- as_utf8_character(into)
  out <- out[!is.na(names(out))]

  as_tibble(out)
}

.str_extract <- function(x, into, regex, convert = FALSE) {
  stopifnot(
    is_string(regex),
    is_character(into)
  )

  out <- .str_match_first(x, regex)
  if (length(out) != length(into)) {
    stop(
      "`regex` should define ", length(into), " groups; ", ncol(matches), " found.",
      call. = FALSE
    )
  }

  # Handle duplicated names
  if (anyDuplicated(into)) {
    pieces <- split(out, into)
    into <- names(pieces)
    out <- map(pieces, pmap_chr, paste0, sep = "")
  }

  into <- as_utf8_character(into)

  non_na_into <- !is.na(into)
  out <- out[non_na_into]
  names(out) <- into[non_na_into]

  out <- as_tibble(out)

  if (convert) {
    out <- map(out, type.convert, as.is = TRUE)
  }

  out
}

.str_match_first <- function(string, regex) {
  loc <- regexpr(regex, string, perl = TRUE)
  loc <- .group_loc(loc)

  out <- lapply(
    seq_len(loc$matches),
    function(i) substr(string, loc$start[, i], loc$end[, i])
  )
  out[-1]
}

.group_loc <- function(x) {
  start <- cbind(as.vector(x), attr(x, "capture.start"))
  end <- start + cbind(attr(x, "match.length"), attr(x, "capture.length")) - 1L

  no_match <- start == -1L
  start[no_match] <- NA
  end[no_match] <- NA

  list(matches = ncol(start), start = start, end = end)
}
