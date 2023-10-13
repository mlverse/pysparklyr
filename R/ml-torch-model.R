#' @importFrom sparklyr ml_save
#' @export
ml_save.ml_torch_model <- function(x, path, overwrite = FALSE, ...) {
  invisible(
    x %>%
      spark_jobj() %>%
      invoke(
        method = "saveToLocal",
        path = path,
        overwrite = overwrite
        )
  )
}
