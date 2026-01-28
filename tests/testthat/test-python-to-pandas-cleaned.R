test_that("Pandas to R type conversion works", {
  sc <- use_test_spark_connect()

  sql_text <- "
    SELECT
    CAST(1 AS BYTE) AS byte_col,
    CAST(2 AS SHORT) AS short_col,
    CAST(3 AS INT) AS int_col,
    CAST(4 AS LONG) AS long_col,
    CAST(1.1 AS FLOAT) AS float_col,
    CAST(2.2 AS DOUBLE) AS double_col,
    CAST(123.45 AS DECIMAL(10,2)) AS decimal_col,
    TRUE AS boolean_col,
    CAST(NULL AS BOOLEAN) AS boolean_col_null,
    'hello' AS string_col,
    CAST('abc' AS BINARY) AS binary_col,
    DATE '2025-01-01' AS date_col,
    CAST(NULL AS DATE) AS date_col_null,
    TIMESTAMP '2025-01-01 12:34:56' AS timestamp_col,
    CAST(NULL AS TIMESTAMP) AS timestamp_col_null
  "

  sql_text_null <- "
    SELECT
    CAST(NULL AS BYTE),
    CAST(NULL AS SHORT),
    CAST(NULL AS INT),
    CAST(NULL AS LONG),
    CAST(NULL AS FLOAT),
    CAST(NULL AS DOUBLE),
    CAST(NULL AS DECIMAL(10,2)),
    CAST(NULL AS BOOLEAN),
    CAST(NULL AS BOOLEAN),
    CAST(NULL AS STRING),
    CAST(NULL AS BINARY),
    CAST(NULL AS DATE),
    CAST(NULL AS DATE),
    CAST(NULL AS TIMESTAMP),
    CAST(NULL AS TIMESTAMP)
  "

  tbl_result <- sparklyr::sdf_sql(
    sc = sc,
    sql = paste(
      sql_text,
      sql_text_null,
      sql_text,
      sql_text_null,
      sep = "UNION ALL"
    )
  ) |>
    python_obj_get() |>
    to_pandas_cleaned()

  expect_vector(tbl_result$byte_col, integer())
  expect_vector(tbl_result$short_col, integer())
  expect_vector(tbl_result$int_col, integer())
  expect_vector(tbl_result$long_col, numeric())
  expect_vector(tbl_result$float_col, numeric())
  expect_vector(tbl_result$double_col, numeric())
  expect_vector(tbl_result$decimal_col, numeric())
  expect_vector(tbl_result$boolean_col, logical())
  expect_vector(tbl_result$boolean_col_null, logical())
  expect_vector(tbl_result$string_col, character())
  expect_vector(tbl_result$binary_col, list())
  expect_vector(tbl_result$date_col, Sys.Date())
  expect_vector(tbl_result$date_col_null, Sys.Date())
  expect_vector(tbl_result$timestamp_col, Sys.time())
  expect_vector(tbl_result$timestamp_col_null, Sys.time())
})
