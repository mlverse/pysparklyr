#' @export
pivot_longer.tbl_pyspark <- function(
    data,
    cols,
    ...,
    cols_vary = "fastest",
    names_to = "name",
    names_prefix = NULL,
    names_sep = NULL,
    names_pattern = NULL,
    names_ptypes = NULL,
    names_transform = NULL,
    names_repair = "check_unique",
    values_to = "value",
    values_drop_na = FALSE,
    values_ptypes = NULL,
    values_transform = NULL) {
  sc <- spark_connection(data)

  spark_df <- tbl_pyspark_sdf(data)

  # This part is so that we can run tidyeval on the resulting
  # Spark Data Frame. We're converting the resulting SDF back
  # into SQL by making it a temp view, and then accesing it via
  # SQL, so we can use `dplyr` commands. We don't do this for
  # the original `data` variable, becuase it `pivot_longer()` may
  # be called after one or several `dplyr` commands. So we have to
  # operate the piped commands first.
  temp_name <- tbl_temp_name()
  te_df <- tbl_pyspark_temp(spark_df, data, temp_name)
  col_names <- te_df %>%
    select(!!enquo(cols)) %>%
    colnames()

  if (length(col_names) == 0) {
    abort("`cols` must select at least one column.")
  }

  # Determining what columns are NOT selected
  col_all <- spark_df$columns
  col_dif <- col_all
  for (col in col_names) {
    col_dif <- col_dif[col_dif != col]
  }

  # Becuase of how PySpark `unpivot` works, if there are no unselected columns
  # I chose to pass the first one, and then remove it after performing the
  # un-pivot operation. Not ideal, but it works
  remove_first <- FALSE
  if (length(col_dif) == 0) {
    col_dif <- col_all[1]
    remove_first <- TRUE
  }

  # If there is a name separator, this loop will process to
  # PySpark unpivot ops
  if (length(names_to) > 1) {
    if (!is.null(names_sep)) {
      output_names <- .str_separate(col_names, names_to, sep = names_sep)
    } else {
      output_names <- .str_extract(col_names, names_to, regex = names_pattern)
    }

    if (length(names_to) > 2) {
      abort("Only two level is supported")
    }

    if (names_to[[1]] == ".value") {
      val_no <- 1
      nm_no <- 2
    } else {
      val_no <- 2
      nm_no <- 1
    }

    val_vals <- output_names[".value"][[1]]

    u_val <- unique(val_vals)

    all_pv <- NULL
    for (i in seq_along(u_val)) {
      nm_rm <- list()
      c_val <- u_val[[i]]
      nm_rm[[val_no]] <- c_val
      nm_rm[[nm_no]] <- names_sep
      nm_rm <- paste0(nm_rm, collapse = "")
      cur_cols <- col_names[which(val_vals == c_val)]
      sel_df <- spark_df$select(c(col_dif, cur_cols))
      for (j in seq_along(cur_cols)) {
        ren_cols <- sub(nm_rm, "", cur_cols)
        sel_df <- sel_df$withColumnRenamed(
          existing = cur_cols[[j]],
          new = sub(nm_rm, "", ren_cols[[j]])
        )
      }

      check_same_types(x = sel_df, col_names = ren_cols)

      all_pv[[i]] <- un_pivot(
        x = sel_df,
        ids = col_dif,
        values = ren_cols,
        names_to = names_to[[nm_no]],
        values_to = c_val,
        remove_first = remove_first,
        values_drop_na = values_drop_na,
        repair = names_repair
      )
    }

    out <- NULL
    for (i in seq_along(all_pv)) {
      no_i <- length(all_pv) - i + 1
      if (no_i > 1) {
        if (is.null(out)) out <- all_pv[[no_i]]
        next_df <- all_pv[[(no_i - 1)]]
        out <- out$join(
          other = next_df,
          on = as.list(c(col_dif, names_to[[nm_no]])),
          how = "full"
        )
      }
    }

    output_cols <- colnames(output_names)
    output_cols <- output_cols[output_cols != ".value"]

    out <- out$select(as.list(c(col_dif, output_cols, u_val)))
  } else {
    check_same_types(x = spark_df, col_names = col_names)

    out <- un_pivot(
      x = spark_df,
      ids = col_dif,
      values = col_names,
      names_to = names_to,
      values_to = values_to,
      remove_first = remove_first,
      values_drop_na = values_drop_na,
      repair = names_repair
    )
  }

  # Cleaning up by removing the temp view with the operations
  # that occurred before pivoting
  dbRemoveTable(sc, temp_name)

  # Creating temp view with the pivoting results
  out <- tbl_pyspark_temp(out, sc)
  gr_out <- group_vars(data)
  if(length(gr_out) > 0) {
    out <- group_by(out, !!! rlang::syms(gr_out))
  }

  out
}

un_pivot <- function(x, ids,
                     values,
                     names_to,
                     values_to,
                     remove_first,
                     values_drop_na,
                     repair
                     ) {
  out <- x$unpivot(
    ids = as.list(ids),
    values = as.list(values),
    variableColumnName = names_to,
    valueColumnName = values_to
  )

  if (remove_first) {
    out <- out$select(list(names_to, values_to))
  }

  if (values_drop_na) {
    out <- out$dropna(subset = values_to)
  }

  col_names <- out$columns

  if(length(unique(col_names)) != length(col_names)) {
    new_names <- vec_as_names(col_names, repair = repair)
  }

  out
}

check_same_types <- function(x, col_names) {
  dtypes <- x$select(col_names)$dtypes
  char_types <- map_chr(dtypes, ~ .x[[2]])
  char_match <- length(unique(char_types)) == 1

  if (!char_match) {
    type_names <- map_chr(dtypes, ~ paste0(.x[[1]], " <", .x[[2]], ">"))
    abort(glue(
      "There is a data type mismatch: {paste0(type_names, collapse = ' ')}"
    ))
  }
}
