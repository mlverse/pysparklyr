#' @importFrom sparklyr ml_save ml_load spark_jobj
#' @importFrom fs path_abs
#' @export
ml_save.ml_connect_model <- function(x, path, overwrite = FALSE, ...) {
  path <- path_abs(path)
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

#TODO: export ml_load() in sparklyr as S3 method
ml_load <- function(sc, path) {
  path <- path_abs(path)
  conn <- python_obj_get(sc)

}

#' @export
spark_jobj.ml_connect_model <- function(x, ...) {
  x$pipeline
}
