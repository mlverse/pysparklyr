# -----------------------------------Hive Reexports ----------------------------

#' Re-exports Hive DBI methods from `odbc`
#' @name HiveReexports

setClass("Hive")

#' @inheritParams DBI::dbQuoteString
#' @rdname HiveReexports
#' @export
setMethod(
  "dbQuoteString", signature("Hive", "character"),
  function(conn, x, ...) {
    if (is(x, "SQL")) {
      return(x)
    }
    x <- gsub("'", "\\\\'", enc2utf8(x))
    if (length(x) == 0L) {
      DBI::SQL(character())
    } else {
      str <- paste0("'", x, "'")
      str[is.na(x)] <- "NULL"
      DBI::SQL(str)
    }
  }
)

#' @inheritParams DBI::dbQuoteIdentifier
#' @rdname HiveReexports
#' @export
setMethod(
  "dbQuoteIdentifier", c("Hive", "character"),
  function(conn, x, ...) {
    conn_quote <- "`"
    if (length(x) == 0L) {
      return(DBI::SQL(character()))
    }
    if (any(is.na(x))) {
      stop("Cannot pass NA to dbQuoteIdentifier()", call. = FALSE)
    }
    if (nzchar(conn_quote)) {
      x <- gsub(conn_quote, paste0(conn_quote, conn_quote), x, fixed = TRUE)
    }
    nms <- names(x)
    res <- DBI::SQL(paste(conn_quote, encodeString(x), conn_quote, sep = ""))
    names(res) <- nms
    res
  }
)
