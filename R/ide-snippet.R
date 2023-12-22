#' A Shiny app that can be used to construct a \code{spark_connect} statement
#'
#' @export
#' @keywords internal
#' @returns A Shiny app
connection_databricks_shinyapp <- function() {
  if (!"shiny" %in% installed.packages()) {
    install_shiny <- showQuestion(
      "Shiny Required",
      "The 'shiny' package is not installed, install?",
      ok = "Install"
    )
    if (identical(install_shiny, TRUE)) {
      install_command <- get("install.packages")
      install_command("shiny")
    }

    if (!"shiny" %in% installed.packages()) {
      cli_abort(
        "The `shiny` package is not installed, please install and retry."
        )
    }
  }

  local_dir <- "inst/rstudio/shinycon"
  if (file.exists(local_dir)) {
    app_dir <- local_dir
  } else {
    app_dir <- system.file("rstudio/shinycon", package = "pysparklyr")
  }
  shinyAppDir <- get("shinyAppDir", envir = asNamespace("shiny"))
  shinyAppDir(app_dir)
}
