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
