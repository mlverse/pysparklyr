#' @export
deploy <- function(appDir = NULL, python = NULL, ...) {
  check_rstudio <- try(RStudio.Version(), silent = TRUE)
  in_rstudio <- !inherits(check_rstudio, "try-error")
  editor_doc <- NULL
  if(is.null(appDir)) {
    if(interactive() && in_rstudio) {
      editor_doc <- getSourceEditorContext()
      appDir <- path_dir(path_expand(editor_doc$path))
      cli_div(theme = cli_colors())
      cli_alert_info("{.header Source:{.emph '{appDir}'}}")
      cli_end()
    }
  }


  # deployApp(
  #   appDir = here::here("doc-subfolder"),
  #   python = "/Users/user/.virtualenvs/r-sparklyr-databricks-14.1/bin/python",
  #   envVars = c("DATABRICKS_HOST", "DATABRICKS_TOKEN"),
  #   lint = FALSE
  # )
}
