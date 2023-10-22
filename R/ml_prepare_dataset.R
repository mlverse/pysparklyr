#' Creates the 'label' and 'features' columns
#'
#' @details
#' At this time, 'Spark ML Connect', does not include a Vector Assembler
#' transformer. The main thing that this function does, is create a 'Pyspark'
#' array column. Pipelines require a 'label' and 'features' columns. Even though
#' it is is single column in the dataset, the 'features' column will contain all
#' of the predictors insde an array. This function also creates a new 'label'
#' column that copies the outcome variable. This makes it a lot easier to remove
#' the 'label', and 'outcome' columns.
#'
#' @returns A `tbl_pyspark`, with either the original columns from `x`, plus the
#' 'label' and 'features' column, or, the 'label' and 'features' columns only.
#'
#' @param x A `tbl_pyspark` object
#' @param formula Used when \code{x} is a \code{tbl_spark}. R formula.
#' @param label The name of the label column.
#' @param features The name(s) of the feature columns as a character vector.
#' @param features_col Features column name, as a length-one character vector.
#' @param label_col Label column name, as a length-one character vector.
#' @param keep_original Boolean flag that indicates if the output will contain,
#' or not, the original columns from `x`. Defaults to `TRUE`.
#' @param ... Added for backwards compatibility. Not in use today.
#' @export
ml_prepare_dataset <- function(
    x,
    formula = NULL,
    label = NULL,
    features = NULL,
    label_col = "label",
    features_col = "features",
    keep_original = TRUE,
    ...
) {

  if(keep_original) {
    lf <- "all"
  } else {
    lf <- "only"
  }

  prep <- ml_prep_dataset(
    x = x,
    formula = formula,
    features = features,
    label = label,
    features_col = features_col,
    label_col = label_col,
    lf = lf
  )

  tbl_pyspark_temp(prep, spark_connection(x))
}

ml_prep_dataset <- function(
    x,
    formula = NULL,
    label = NULL,
    features = NULL,
    label_col = "label",
    features_col = "features",
    lf = c("only", "all")
) {
  lf <- match.arg(lf)

  pyspark <- x %>%
    spark_connection() %>%
    import_main_library()

  if (!is.null(formula)) {
    f <- ml_formula(formula, x)
    features <- f$features
    label <- f$label
  } else {
    if(is.null(features) && is.null(label)) {
      return(x)
    }
  }

  ret <- python_obj_get(x)
  if(!is.null(label)) {
    ret <- ret$withColumn(label_col, ret[label])
  }
  features_array <- pyspark$sql$functions$array(features)
  ret <- ret$withColumn(features_col, features_array)

  if(lf == "only") {
    ret <- ret$select(c(label_col, features_col))
    attr(ret, "features")  <- features
    if(!is.null(label)) {
      attr(ret, "label")  <- label
    }
  }
  ret
}
