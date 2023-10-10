#' @export
ml_logistic_regression.tbl_pyspark <- function(
    x, formula = NULL, fit_intercept = TRUE,
    elastic_net_param = NULL, reg_param = NULL, max_iter = 100,
    threshold = NULL, thresholds = NULL, tol = 1e-06,
    weight_col = NULL, aggregation_depth = NULL,
    lower_bounds_on_coefficients = NULL, lower_bounds_on_intercepts = NULL,
    upper_bounds_on_coefficients = NULL, upper_bounds_on_intercepts = NULL,
    features_col = "features", label_col = "label", family = "auto",
    prediction_col = "prediction", probability_col = "probability",
    raw_prediction_col = "rawPrediction",
    uid = random_string("logistic_regression_"), ...) {

  args <- c(as.list(environment()), list(...))

  ml_connect_not_supported(
    args = args,
    not_supported = c(
      "elastic_net_param", "reg_param",
      "threshold", "aggregation_depth"
    )
  )




  pyspark <- import("pyspark")
  connect_classification <- import("pyspark.ml.connect.classification")

  if (!is.null(formula)) {
    f <- ml_formula(formula, x)
    features <- f$features
    label <- f$label
  } else {
    features <- features_col
    label <- label_col
  }

  features_array <- pyspark$sql$functions$array(features)

  x_df <- x[[1]]$session

  tbl_features <- x_df$withColumn("features", features_array)
  tbl_label <- tbl_features$withColumnRenamed(label, "label")
  tbl_prep <- tbl_label$select("label", "features")
  log_reg <<- connect_classification$LogisticRegression()

  args$x <- NULL
  args$formula <- NULL

  args <- args %>%
    discard(is.null)

  new_names <- args %>%
    names() %>%
    map_chr(snake_to_camel)

  new_args <- set_names(args, new_names)

  prep_reg <- do.call(connect_classification$LogisticRegression, new_args[2:5])

  fitted <- prep_reg$fit(tbl_prep)
  fitted
}

set_multiple_attributes <- function(x, ...) {
  args <- unlist(list(...))
  for (i in seq_along(args)) {
    arg <- args[i]
    sepd <- unlist(strsplit(names(arg), "_"))
    arg_name <- snake_to_camel(names(arg))
    print(arg_name)
    print(paste0("--- ", arg))
    x[[arg_name]] <- arg
  }
  x
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
  x <- map_chr(
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
  )

  x <- x[x != ""]

  if (length(x) > 0) {
    cli_abort(c(
      "The following argument(s) are not supported by Spark Connect:",
      x,
      "Set it(them) to `NULL` and try again."
    ))
  }
}
