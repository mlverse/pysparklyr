#' @export
sdf_schema.tbl_pyspark <- function(
  x,
  expand_nested_cols = NULL,
  expand_struct_cols = NULL
) {
  check_arg_supported(expand_nested_cols)
  check_arg_supported(expand_struct_cols)

  x_sdf <- python_sdf(x)
  x_schema <- x_sdf$schema
  x_schema$fields %>%
    map(~ {
      dt <- as.character(.x$dataType)
      dt <- substr(dt, 1, nchar(dt) - 2)
      list(name = .x$name, type = dt)
    }) %>%
    set_names(x_schema$names)
}
