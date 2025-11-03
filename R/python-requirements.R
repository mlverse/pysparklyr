#' Writes the 'requirements.txt' file, containing the needed Python libraries
#' @description This is a helper function that it is meant to be used for deployments
#' of the document or application. By default, `deploy_databricks()` will run this
#' function the first time you use that function to deploy content to Posit Connect.
#' @param envname The name of, or path to, a Python virtual environment.
#' @param destfile Target path for the requirements file. Defaults to 'requirements.txt'.
#' @param overwrite Replace the contents of the file if it already exists?
#' @param ... Additional arguments passed to `reticulate::py_list_packages()`
#' @returns No value is returned to R. The output is a text file with the
#' list of Python libraries.
#' @export
requirements_write <- function(
  envname = NULL,
  destfile = "requirements.txt",
  overwrite = FALSE,
  ...
) {
  cli_div(theme = cli_colors())

  if (file_exists(destfile)) {
    if (overwrite) {
      file_delete(destfile)
    } else {
      cli_abort(c(
        "{.header File }{.emph '{path_file(destfile)}'} {.header already exists}",
        " " = "{.header Use} {.code overwrite = TRUE} {.header if you wish to replace}"
      ))
    }
  }

  pkgs <- py_list_packages(
    envname = envname,
    ...
  )

  writeLines(
    c(
      "# Automatically created by `sparklyr`", "",
      pkgs$requirement
    ),
    con = destfile
  )

  txt_pkgs_lbl <- c(
    "pyspark",
    "databricks.connect",
    "databricks-connect"
  ) %>%
    map_chr(~ {
      x <- pkgs$version[pkgs$package == .x]
      if (length(x) == 0) {
        x <- ""
      } else {
        x <- glue("'{.x}' '{x}'")
      }
      x
    }) %>%
    discard(~ .x == "") %>%
    reduce(paste, collapse = ",", .init = "")

  if (txt_pkgs_lbl != "") {
    line1 <- "{.header Python library requirements for}{.emph {txt_pkgs_lbl}}"
  } else {
    line1 <- "{.header Python library requirements}"
  }

  cli_inform(c(
    "i" = line1,
    " " = "{.header File}: {path_expand(destfile)}"
  ))
  cli_end()
  invisible()
}
