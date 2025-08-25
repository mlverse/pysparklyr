ml_formula <- function(f, data) {
  col_data <- colnames(data)

  temp_tbl <- rep(1, times = length(col_data)) %>%
    purrr::set_names(col_data) %>%
    as.list() %>%
    as.data.frame()

  f_terms <- terms(f, data = temp_tbl)

  f_factors <- attr(f_terms, "factors")

  feat_names <- colnames(f_factors)
  row_f <- rownames(f_factors)

  for (i in feat_names) {
    in_data <- i %in% col_data
    if (!in_data) {
      cli_abort(c(
        "Formula resulted in an invalid parameter set\n",
        "- Only '+' is supported."
      ), call = NULL)
    }
  }

  label <- NULL
  for (i in row_f) {
    if (!(i %in% feat_names)) {
      label <- c(label, i)
    }
  }
  list(
    label = label,
    features = feat_names
  )
}

snake_to_camel <- function(x) {
  s <- unlist(strsplit(x, "_"))
  x <- paste(
    toupper(substring(s, 1, 1)), substring(s, 2),
    sep = "", collapse = ""
  )
  paste(
    tolower(substring(x, 1, 1)), substring(x, 2),
    sep = "", collapse = ""
  )
}

ml_connect_not_supported <- function(args, not_supported = c()) {
  x <- map(
    not_supported,
    ~ {
      if (.x %in% names(args)) {
        arg <- args[names(args) == .x]
        if (!is.null(arg[[1]])) {
          ret <- paste0("{.emph - `", names(arg), "`}")
        } else {
          ret <- ""
        }
      }
    }
  ) %>%
    discard(is.null) %>%
    as.character()

  x <- x[x != ""]

  if (length(x) > 0) {
    cli_abort(c(
      "The following argument(s) are not supported by Spark Connect:",
      x,
      "Set it/them to `NULL` and try again."
    ))
  }
}

ml_execute <- function(args, python_library, fn, sc) {
  py_lib <- import(python_library)

  # Removes any variable with a "." prefix
  args <- args[substr(names(args), 1, 1) != "."]

  args$x <- NULL

  args <- discard(args, is.null)

  new_names <- args %>%
    names() %>%
    map_chr(snake_to_camel)

  new_args <- set_names(args, new_names)

  invisible(
    jobj <- do.call(
      what = py_lib[fn],
      args = new_args
    )
  )

  as_spark_pyobj(jobj, sc)
}

get_params <- function(x) {
  py_model <- python_obj_get(x)
  m_params <- py_model$params
  m_map <- py_model$extractParamMap()
  m_map_names <- m_map %>%
    names() %>%
    strsplit("__") %>%
    map(~ .x[[2]]) %>%
    as.character() %>%
    sort()

  m_param_names <- m_params %>%
    map(~ .x$name) %>%
    as.character()

  m_map_names %>%
    map(~ {
      c_param_name <- m_params[which(.x == m_param_names)]
      c_map_name <- m_map[which(.x == m_map_names)]
      list(
        name = .x,
        value = c_map_name[[1]],
        description = c_param_name[[1]]$doc
      )
    })
}

ml_installed <- function(envname = NULL) {
  py_check_installed(
    envname = envname,
    libraries = pysparklyr_env$ml_libraries,
    msg = "Required Python libraries to run ML functions are missing"
  )
}

ml_get_params <- function(x) {
  py_x <- get_spark_pyobj(x)
  params <- invoke(py_x, "params")
  params %>%
    map(~ {
      nm <- .x$name
      nm <- paste0("get", toupper(substr(nm, 1, 1)), substr(nm, 2, nchar(nm)))
      tr <- try(invoke(py_x, nm), silent = TRUE)
      if (inherits(tr, "spark_pyobj")) {
        tr <- tr %>%
          python_obj_get() %>%
          py_to_r()
      }
      out <- ifelse(inherits(tr, "try-error"), list(), list(tr))
      set_names(out, .x$name)
    }) %>%
    purrr::flatten() %>%
    discard(is.null)
}
