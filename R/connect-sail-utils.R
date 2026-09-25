sail_versions <- function(version = NULL) {
  cli_div(theme = cli_colors())
  sail_info <- try(
    python_library_info("pysail", version, verbose = FALSE, fail = FALSE),
    silent = TRUE
  )
  if (inherits(sail_info, "try-error")) {
    sail_info <- NULL
  }
  if (is.null(version)) {
    if (is.null(sail_info)) {
      cli_abort(
        c(
          "Could not find the latest {.pkg pysail} version on PyPI.org",
          " " = "Please provide a Sail {.code version}"
        ),
        call = NULL
      )
    }
    version <- sail_info$version
  }
  client_version <- try(
    sail_client_pin(sail_info$requires_dist),
    silent = TRUE
  )
  if (inherits(client_version, "try-error")) {
    client_version <- NULL
  }
  if (is.null(client_version)) {
    cli_alert_warning(paste0(
      "{.header Could not find the {.emph pyspark-client} version that }",
      "{.emph pysail} {.header {version} requires. Using the newest one.}"
    ))
  }
  list(
    backend_version = version,
    main_library_version = client_version
  )
}

# Returns the `pyspark-client` version pinned in `pysail`'s `requires_dist`.
# Looks in every entry, not only the `test` extra, in case the pin moves.
# A range resolves to the newest matching release.
sail_client_pin <- function(requires_dist) {
  reqs <- as.character(requires_dist)
  reqs <- trimws(sub(";.*", "", reqs))
  req_names <- sub("^([A-Za-z0-9._-]+).*", "\\1", reqs)
  req_names <- gsub("[-_.]+", "-", tolower(req_names))
  pin <- reqs[req_names == "pyspark-client"]
  if (length(pin) == 0) {
    return(NULL)
  }
  spec <- sub("^[A-Za-z0-9._-]+\\s*(\\[.*\\])?", "", pin[[1]])
  spec <- gsub("[() ]", "", spec)
  specs <- strsplit(spec, ",")[[1]]
  specs <- specs[specs != ""]
  if (length(specs) == 0) {
    return(NULL)
  }
  if (length(specs) == 1 && grepl("^===?[0-9.]+$", specs)) {
    return(sub("^===?", "", specs))
  }
  releases <- names(query_pypi("pyspark-client", timeout = 2)$releases)
  releases <- releases[grepl("^[0-9]+(\\.[0-9]+)*$", releases)]
  matches <- Filter(
    function(x) all(vapply(specs, version_meets_spec, logical(1), x = x)),
    releases
  )
  if (length(matches) == 0) {
    return(NULL)
  }
  as.character(max(package_version(matches)))
}

version_meets_spec <- function(x, spec) {
  op <- sub("^([<>=!~]+).*", "\\1", spec)
  target <- sub("^[<>=!~]+", "", spec)
  if (grepl("\\.\\*$", target)) {
    prefix <- sub("\\.\\*$", "", target)
    matched <- x == prefix || startsWith(x, paste0(prefix, "."))
    return(if (op == "!=") !matched else matched)
  }
  x <- package_version(x)
  target <- package_version(target)
  switch(
    op,
    "==" = x == target,
    "===" = x == target,
    "!=" = x != target,
    ">=" = x >= target,
    ">" = x > target,
    "<=" = x <= target,
    "<" = x < target,
    "~=" = {
      parts <- unlist(target)
      upper <- package_version(paste0(
        c(parts[seq_len(length(parts) - 2)], parts[length(parts) - 1] + 1),
        collapse = "."
      ))
      x >= target && x < upper
    },
    FALSE
  )
}

# `pysail` pinned to the full version PyPI resolves (`0.7` becomes `0.7.0`),
# the same as the main library. Its `requires_dist` is only extras, so it is
# not added.
sail_package <- function(version) {
  info <- python_library_info("pysail", version, verbose = FALSE, fail = FALSE)
  if (!is.null(info)) {
    version <- info$version
  } else if (version == version_prep(version)) {
    version <- paste0(version, ".*")
  }
  paste0("pysail==", version)
}
