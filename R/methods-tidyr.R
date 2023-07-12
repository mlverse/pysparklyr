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
    select(!! cols) %>%
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

  un_pivoted <- spark_df$unpivot(
    ids = as.list(col_dif),
    values = as.list(col_names),
    variableColumnName = names_to,
    valueColumnName = values_to
    )

  # Cleaning up by removing the temp view with the operations
  # that ocurred before pivoting
  dbRemoveTable(sc, temp_name)


  # Creating temp view with the pivoting results
  up_name <- glue("sparklyr_tmp_{random_string()}")
  un_pivoted$createOrReplaceTempView(up_name)
  out <- tbl(sc, up_name)

  # This si where we remove the extrenous column if we had
  # to use the first column as dummy. Would like to figure
  # out how to do the column selection at the DataFrame level
  # and not the SQL level, but it'll do for now.
  if(remove_first) {
    out <- select(out, - expr(!! col_dif))
  }
  out
 }
