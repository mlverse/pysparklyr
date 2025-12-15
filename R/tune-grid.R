#' @export
spark_tune_grid <- function(
  object,
  preprocessor,
  resamples,
  ...,
  param_info = NULL,
  grid = 10,
  metrics = NULL,
  eval_time = NULL,
  control = control_grid(parallel_over = "everything"),
  sc,
  grid_partitions = NULL
) {
  wf <- workflow() |>
    add_model(object) |>
    add_recipe(preprocessor)
  wf_metrics <- check_metrics_arg(metrics, wf, call = rlang::caller_env())
  static <- list(
    wflow = wf,
    param_info = tune::check_parameters(wf),
    configs = get_config_key(wf_grid, wf),
    post_estimation = workflows::.workflow_postprocessor_requires_fit(wf),
    metrics = wf_metrics,
    metric_info = tibble::as_tibble(wf_metrics),
    pred_types = determine_pred_types(wf, wf_metrics),
    eval_time = NULL,
    split_args = rsample::.get_split_args(resamples),
    control = control,
    pkgs = "tidymodels",
    strategy = "sequential",
    data = list(fit = NULL, pred = NULL, cal = NULL)
  )

  # Creating unique file names to avoid re-uploading if possible
  hash_static <- rlang::hash(static)
  hash_resamples <- rlang::hash(resamples)
  hash_r_seed <- rlang::hash(.Random.seed)

  # Uploads the files to the Spark temp folder, this function skips the upload
  # if the hashed file name has already been uploaded during the current session
  spark_session_add_file(wf, sc, hash_static)
  spark_session_add_file(resamples, sc, hash_resamples)
  spark_session_add_file(.Random.seed, sc, hash_r_seed)

  # Uses the `loop_call` function as the base of the UDF that will be sent to
  # the Spark session. It works by modifying the text of the function, specifically
  # the file names it reads to load the different R object components
  root_folder <- spark_session_root_folder(sc)
  grid_code <- paste0(deparse(loop_call), collapse = "\n")
  grid_code <- sub("path/to/root", root_folder, grid_code)
  grid_code <- sub("static.rds", path(hash_static, ext = "rds"), grid_code)
  grid_code <- sub("resamples.rds", path(hash_resamples, ext = "rds"), grid_code)
  grid_code <- sub("r_seed.rds", path(hash_r_seed, ext = "rds"), grid_code)

  # Creating the tune grid data frame
  res_id_df <- map_df(
    seq_len(length(resamples$id)),
    \(x) data.frame(index = x, id = resamples$id[[x]])
  )
  full_grid <- grid |>
    dplyr::cross_join(res_id_df) |>
    dplyr::arrange(index)

  # The pandas mapping function requires all of the output column names
  # and types to be specified. Types have to be converted too
  cols <- imap_chr(
    grid,
    \(x, y) {
      x_class <- class(x)
      if (x_class == "character") {
        p_class <- "string"
      } else if (x_class == "numeric") {
        p_class <- "double"
      } else {
        p_class <- x_class
      }
      paste0(y, " ", x_class, ",")
    }
  ) |>
    paste0(collapse = " ") |>
    paste("metric string, estimator string, estimate double, index integer")

  sc_obj <- spark_session(sc)


  # The grid is copied to Spark, it will be repartitioned if `grid_paritions`
  # is set. If not set, Spark will decide how many partitions the data will have,
  # that impacts how many discrete jobs there will be set for this run
  tbl_grid <- sc_obj$createDataFrame(full_grid[1, colnames(full_grid) != "id"])
  if (!is.null(grid_partitions)) {
    tbl_grid <- tbl_grid$repartition(as.integer(grid_partitions))
  }
  #              ****** This is where the magic happens ******
  # The grid hs passed mapInPandas() which will run the resulting code in the
  # Spark session in as many parallel jobs as tbl_grid is partitioned by
  tuned_results <- tbl_grid |>
    sa_in_pandas(
      .f = grid_code,
      .schema = cols,
      .as_sdf = FALSE,
    ) |>
    collect()

  # Finalizes metrics tables by adding the 'id' label, and `.config`, and
  # restoring the 'dot' prefix to the metric fields (Spark does not like
  # names with dots)
  tuned_results <- tuned_results |>
    dplyr::rename(
      .metric = metric,
      .estimator = estimator,
      .estimate = estimate
    ) |>
    dplyr::left_join(res_id_df, by = "index") |>
    dplyr::select(-index) |>
    dplyr::left_join(get_config_key(grid, wf), by = colnames(grid)) |>
    dplyr::arrange(.config)

  # Converts metrics to list separated by id's
  res_names <- colnames(tuned_results)
  metrics_names <- res_names[res_names != "id"]
  metrics_map <- map(
    unique(tuned_results$id),
    \(x) tuned_results[tuned_results$id == x, metrics_names]
  ) |>
    set_names(unique(tuned_results$id))

  # Creates dummy 'notes' table
  notes <- list(tibble(
    location = character(0),
    type = character(0),
    note = character(0),
    trace = list()
  ))

  # Joins the resamples, metrics and notes tables, and adds needed attributes
  out <- resamples |>
    as_tibble() |>
    mutate(
      .metrics = metrics_map,
      .notes = notes
    )
  class(out) <- c("tune_results", class(out))
  attr(out, "metrics") <- metrics
  attr(out, "outcomes") <- tune::outcome_names(wf)
  attr(out, "parameters") <- tune::check_parameters(wf)
  attr(out, "rset_info") <- pull_rset_attributes(resamples)
  out
}

# `x` only contains a table with the grid containing every single combination
loop_call <- function(x) {
  library(tidymodels)

  # ------------------- Updates from caller function section -------------------
  root_folder <- "path/to/root"
  # This weird check here is to make it easy to debug/develop this function
  if (root_folder == "path/to/root") {
    root_folder <- Sys.getenv("TEMP_SPARK_GRID")
  }
  # Loads the needed R objects from disk
  static <- readRDS(file.path(root_folder, "static.rds"))
  resamples <- readRDS(file.path(root_folder, "resamples.rds"))
  # To match the 'seed' from the caller R seesion
  assign(".Random.seed", readRDS(file.path(root_folder, "r_seed.rds")))
  # ----------------------------------------------------------------------------
  out <- NULL
  # Spark will more likely send more than one row (combination) in `x`. It
  # will depend on how the grid data frame was partitioned inside Spark.
  for (i in seq_len(nrow(x))) {
    curr_x <- x[i, ]
    curr_resample <- resamples[curr_x$index, ]
    curr_resample <- dplyr::mutate(curr_resample, .seeds = list(list()))
    curr_grid <- curr_x[, colnames(curr_x) != "index"]
    res <- tune:::loop_over_all_stages(curr_resample, curr_grid, static)
    res_df <- Reduce(rbind, res$.metrics)
    out <- rbind(out, res_df)
  }
  out
}

spark_session_root_folder <- function(sc) {
  # A unique GUID is assigned to the Spark connection
  # this is used to pull the root folder only one time. It will save it to
  # a package level environment variable that will be retained while the
  # connection is current.
  connection_id <- sc[["connection_id"]]
  artifacts <- pysparklyr_env[["artifacts"]][[connection_id]]
  if (is.null(artifacts)) {
    py_run_string("
from pyspark.sql.functions import udf
from pyspark.sql.types import StringType
from pyspark import SparkFiles
def get_root_dir(dummy_input):
    root_dir = SparkFiles.getRootDirectory()
    return f'{root_dir}'
root_dir_udf = udf(get_root_dir, StringType())
")
    main <- reticulate::import_main()
    sc_obj <- spark_session(sc)
    temp_df <- sc_obj$createDataFrame(data.frame(a = 1))
    root_df <- temp_df$withColumn("root_folder", main$root_dir_udf("a"))$collect()
    root_folder <- root_df[[1]]$asDict()$root_folder
    artifacts <- list(root_folder = root_folder, files = c())
    pysparklyr_env$artifacts[[connection_id]] <- artifacts
  }
  pysparklyr_env$artifacts[[connection_id]]$root_folder
}

spark_session_add_file <- function(x, sc, file_name = NULL) {
  # Tracks in a environment variable which file names have already been
  # uploaded to avoid doing it again. This is why the hashed values of
  # the object in `x` is preferred, which ensure proper tracking of the
  # actual objects that have been uploaded
  invisible(spark_session_root_folder(sc))
  connection_id <- sc[["connection_id"]]
  artifacts <- pysparklyr_env[["artifacts"]][[connection_id]]
  if (is.null(file_name)) {
    file_name <- rlang::hash(x)
  }
  files <- artifacts[["files"]]
  if (!file_name %in% artifacts[["files"]]) {
    temp_file <- path_temp(file_name, ext = "rds")
    saveRDS(x, temp_file)
    sc_obj <- spark_session(sc)
    sc_obj$addArtifact(temp_file, file = TRUE)
    file_delete(temp_file)
    pysparklyr_env[["artifacts"]][[connection_id]]$files <- c(file_name, files)
  }
  invisible()
}
