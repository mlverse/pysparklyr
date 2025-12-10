library(tidymodels)
root_folder <- "root-folder-path"
pre_processing <- readRDS(file.path(root_folder, "preprocessing.rds"))
model <- readRDS(file.path(root_folder, "model.rds"))
resamples <- readRDS(file.path(root_folder, "resamples.rds"))
out <- NULL
for(i in seq_len(nrow(x))) {
  curr_x <- x[i, ]
  resample <- get_rsplit(resamples, curr_x$index)
  params <- as.list(curr_x[, 1:(length(curr_x)-2)])
  re_training <- as.data.frame(resample, data = "analysis")
  fitted_workflow <- workflow() |>
    add_recipe(finalize_recipe(pre_processing, params)) |>
    add_model(finalize_model(model, params)) |>
    fit(re_training)
  re_testing <- as.data.frame(resample, data = "assessment")
  wf_predict <- predict(fitted_workflow, re_testing)
  colnames(wf_predict) <- ".predictions"
  fin_bind <- cbind(re_testing, wf_predict)
  var_info <- pre_processing$var_info
  outcome_var <- var_info$variable[var_info$role == "outcome"]
  fin_metrics <- metrics(fin_bind, truth = outcome_var,  estimate = ".predictions")
  curr <- cbind(as.data.frame(params), fin_metrics)
  curr$id <- curr_x$id
  colnames(curr) <- c(names(params), "metric", "estimator", "estimate", "id")
  out <- rbind(out, curr)
}
out
