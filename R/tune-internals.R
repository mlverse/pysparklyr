determine_pred_types <- function(wflow, metrics) {
  model_mode <- extract_spec_parsnip(wflow)$mode

  pred_types <- unique(metrics_info(metrics)$type)
  # Does not support post processing... yet (tailor)
  # if (has_tailor(wflow)) {
  #   post <- extract_postprocessor(wflow)
  #   post_out <- purrr::map(post$adjustments, "outputs")
  #   post_in <- purrr::map(post$adjustments, "inputs")
  #   post_types <- unlist(c(post_out, post_in))
  #   post_types[grepl("probability", post_types)] <- "prob"
  #   post_cls <- purrr::map(post$adjustments, class)
  #   post_cls <- unlist(post_cls)
  #   if (any(post_cls == "probability_calibration")) {
  #     post_types <- c(post_types, "class", "prob")
  #   }
  #   post_cls <- unique(post_cls)
  #   pred_types <- unique(c(pred_types, post_types))
  # }

  if (any(pred_types == "everything")) {
    if (model_mode == "regression") {
      pred_types <- c(pred_types, "numeric")
    } else if (model_mode == "classification") {
      pred_types <- c(pred_types, "class", "prob")
    } else if (model_mode == "censored regression") {
      pred_types <- c(
        pred_types,
        "static_survival_metric",
        "dynamic_survival_metric"
      )
    } else {
      cli::cli_abort(
        "No prediction types are known for mode {.val model_mode}."
      )
    }

    pred_types <- pred_types[pred_types != "everything"]
  }

  sort(unique(pred_types))
}


get_config_key <- function(grid, wflow) {
  info <- tune_args(wflow)
  key <- grid

  only_param <- setdiff(info$id, names(grid))
  if (length(only_param) > 0) {
    cli::cli_abort(
      "Some parameters are tagged for tuning but are not in the grid:
      {.arg {only_param}}",
      call = NULL
    )
  }

  only_grid <- setdiff(names(grid), info$id)
  if (length(only_grid) > 0) {
    cli::cli_abort(
      "Some parameters are in the grid but are not tagged for tuning:
      {.arg {only_grid}}",
      call = NULL
    )
  }

  pre_param <- info$id[info$source == "recipe"]
  if (length(pre_param) > 0) {
    key <- make_config_labs(grid, pre_param) |>
      dplyr::full_join(key, by = pre_param)
  } else {
    key <- key |>
      dplyr::mutate(pre = "pre0")
  }

  mod_param <- info$id[info$source == "model_spec"]
  if (length(mod_param) > 0) {
    key <- make_config_labs(grid, mod_param, "mod") |>
      dplyr::full_join(key, by = mod_param)
  } else {
    key <- key |>
      dplyr::mutate(mod = "mod0")
  }

  post_param <- info$id[info$source == "tailor"]
  if (length(post_param) > 0) {
    key <- make_config_labs(grid, post_param, "post") |>
      dplyr::full_join(key, by = post_param)
  } else {
    key <- key |>
      dplyr::mutate(post = "post0")
  }

  # in the case of resampling without tuning, grid and thus key are 0-row tibbles
  if (nrow(key) < 1) {
    key <- dplyr::tibble(
      pre = "pre0",
      mod = "mod0",
      post = "post0"
    )
  }

  key$.config <- paste(key$pre, key$mod, key$post, sep = "_")
  key$.config <- gsub("_$", "", key$.config)
  key |>
    dplyr::arrange(.config) |>
    dplyr::select(dplyr::all_of(info$id), .config)
}

make_config_labs <- function(grid, param, val = "pre") {
  res <- grid |>
    dplyr::select(dplyr::all_of(param)) |>
    dplyr::distinct() |>
    dplyr::arrange(!!!rlang::syms(param)) |>
    dplyr::mutate(
      num = format(dplyr::row_number()),
      num = gsub(" ", "0", num),
      {{ val }} := paste0(val, num)
    ) |>
    dplyr::select(-num)

  res
}
