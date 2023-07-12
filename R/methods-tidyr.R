#' @importFrom tidyr pivot_longer
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
  values_transform = NULL
  ){

  sc <- spark_connection(data)

  spark_df <- python_conn(sc)$sql(remote_query(data))

  # This part is so that we can run tidyeval on the resulting
  # Spark Data Frame. We're converting the resulting SDF back
  # into SQL by making it a temp view, and then accesing it via
  # SQL, so we can use `dplyr` commands. We don't do this for
  # the original `data` variable, becuase it `pivot_longer()` may
  # be called after one or several `dplyr` commands. So we have to
  # operate the piped commands first.
  temp_name <- glue("sparklyr_tmp_{random_string()}")
  spark_df$createOrReplaceTempView(temp_name)
  te_df <- tbl(sc, temp_name)
  col_names <- te_df %>%
    select(!! enquo(cols)) %>%
    colnames()

  # Determining what columns are NOT selected
  col_all <- spark_df$columns
  col_dif <- col_all
  for(col in col_names) {
    col_dif <- col_dif[col_dif != col]
  }

  # Becuase of how PySpark `unpivot` works, if there are no unselected columns
  # I chose to pass the first one, and then remove it after performing the
  # un-pivot operation. Not ideal, but it works
  remove_first <- FALSE
  if(length(col_dif) == 0) {
    col_dif <- col_all[1]
    remove_first <- TRUE
  }

  if(!is.null(names_sep)) {

    if(length(names_to) > 2) {
      abort("Only two level is supported")
    }

    if(names_to[[1]] == ".value") {
      val_no <- 1
      nm_no <- 2
    } else {
      val_no <- 2
      nm_no <- 1
    }

    val_vals <- col_names %>%
      strsplit("_") %>%
      map(~ .x[[val_no]]) %>%
      unlist()

    nm_vals <- col_names %>%
      strsplit("_") %>%
      map(~ .x[[nm_no]]) %>%
      unlist()

    u_val <- unique(val_vals)
    u_nm <- unique(nm_vals)

    all_pv <- NULL
    for(i in seq_along(u_val)) {
      nm_rm <- list()
      c_val <- u_val[[i]]
      nm_rm[[val_no]] <- c_val
      nm_rm[[nm_no]] <- names_sep
      nm_rm <- paste0(nm_rm, collapse = "")
      cur_cols <- col_names[which(val_vals == c_val)]
      sel_df <- spark_df$select(c(col_dif, cur_cols))
      for(i in seq_along(cur_cols)) {
        ren_cols <-  sub(nm_rm, "", cur_cols)
        sel_df <- sel_df$withColumnRenamed(
          existing = cur_cols[[i]],
          new = sub(nm_rm, "", ren_cols[[i]])
          )
      }

      all_pv[[i]] <- sel_df$unpivot(
        ids = as.list(col_dif),
        values = as.list(ren_cols),
        variableColumnName = names_to[[nm_no]],
        valueColumnName = c_val
      )

    }

    un_pivoted <- all_pv[[2]]$join(
      other = all_pv[[1]],
      on = as.list(c(col_dif, names_to[[nm_no]])),
      how = "full"
      )

  } else {
    un_pivoted <- spark_df$unpivot(
      ids = as.list(col_dif),
      values = as.list(col_names),
      variableColumnName = names_to,
      valueColumnName = values_to
    )
  }

  # Cleaning up by removing the temp view with the operations
  # that occurred before pivoting
  dbRemoveTable(sc, temp_name)


  # Creating temp view with the pivoting results
  up_name <- glue("sparklyr_tmp_{random_string()}")
  un_pivoted$createOrReplaceTempView(up_name)
  out <- tbl(sc, up_name)

  # This is where we remove the extraneous column if we had
  # to use the first column as dummy. Would like to figure
  # out how to do the column selection at the DataFrame level
  # and not the SQL level, but it'll do for now.
  if(remove_first) {
    out <- select(out, - sym(!! col_dif))
  }

  if(values_drop_na) {
    out <- filter(out, !is.na(!! sym(values_to)))
  }
  out
 }
