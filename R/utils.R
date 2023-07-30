check_arg_supported <- function(x, msg = NULL) {
  arg <- enquo(x)
  if(!is.null(x)) {
    if(is.null(msg)) {
      arg_name <- deparse(x)
      msg <- glue(
        paste(
          "The '{rlang::as_label(arg)}' argument is not currently",
          "supported for this back-end"
        ))
    }
    cli_abort(msg)
  }
  invisible()
}