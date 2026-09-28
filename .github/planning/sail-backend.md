# Plan: add a Sail back-end to pysparklyr

## Decisions

- `spark_connect(master = "local", method = "sail")` starts a Sail server
  inside the R session and stops it on `spark_disconnect()`. Any other
  `master`, for example `sc://localhost:50051`, connects to a server that is
  already running.
- The client library is `pyspark-client`, not `pyspark`. The environment never
  contains both.
- `pysail` is installed in the connection environment, pinned to
  `backend_version`. Its `requires_dist` is only read for the
  `pyspark-client` pin, never installed.
- `version` splits into `backend_version` and `main_library_version`. The
  second defaults to the first.

## Phase 1: split `version`

Changes shared code used by every connection method.

1. **Split `version`** in `use_envname()` and `python_requirements()`
   (`R/python-use-envname.R`), and in `install_as_job()` and
   `install_environment()` (`R/python-install.R`).
   - `backend_version`: env name, install hint, install prompt, the
     `install_{backend}()` call, `databricks_dbr_python()`.
   - `main_library_version`: PyPI lookup, `"latest"` resolution, the
     `==` pin, and the `ml_version` comparison that sets `add_torch`.
   - Lines 67-70 (rename env to latest library version): only run when
     `main_library_version` defaults to `backend_version`.
   - Lines 104-113 ("not yet available" message): skip when
     `main_library_version` is passed separately.
   - Set `install_recent` when `python_library_info()` at line 59 returns
     `NULL`. Today it is left unset and line 104 errors.

2. **Update callers** to `backend_version`:
   `R/connect-spark.R:24`, `R/connect-databricks.R:49`,
   `R/connect-snowflake.R:21`, `R/start-stop-service.R:48`, `R/deploy.R:276`,
   `R/python-install.R:214`.

3. **Merge the package lists.** `install_environment()` in
   `R/python-install.R` builds its own hardcoded list. Make it call
   `python_requirements()` instead, so a Sail environment will not get
   `databricks-sdk` or `google-api-python-client`. Keep `add_torch` and
   `ver_name` in `install_environment()`.

4. **Test that nothing broke.**
   - Before the change, add snapshot tests for the env names and package
     lists that Spark Connect, Databricks, and Snowflake get. Mock
     `python_library_info()` so new PyPI releases do not change them. After the
     change, env names and `python_requirements()` lists must not change.
     The `install_environment()` lists will change on purpose, because they
     now come from `requires_dist`; check the snapshot diff by hand.
   - `devtools::test()` and `devtools::check()` pass.
   - Connect by hand to Spark Connect, Databricks, and Snowflake, with and
     without a `version`.

## Phase 2: the `sail` connection method

1. **Add `sail_versions(version)`.** Returns
   `list(backend_version, main_library_version)`.
   - Query `pysail` on PyPI (`python_library_info()`). If `version` is
     `NULL`, use the newest release as `backend_version`.
   - Find `pyspark-client` in all of `requires_dist`, ignoring case and
     `-`/`_`. If the pin is a range, take the newest matching release.
   - Wrap in `try()`. If the pin is not found, return `NULL` for
     `main_library_version`, which means the newest `pyspark-client`, and
     show a message. Stay silent otherwise.
   - If `version` is `NULL` and `pysail` cannot be found, abort with a
     Sail-specific message.
   - When the user gives a version, keep the client lookup lazy so an exact
     env match or an explicit `envname` makes no network call.

2. **Add `pysail` to the Sail package list.** `python_requirements()` adds
   `pysail` next to `pyspark-client`, pinned to the full version from PyPI
   (`0.7.1`), not the user's `0.7`: pip reads `==0.7` as `0.7.0`. If PyPI
   cannot be reached, use `==0.7.*`, as the main library does. Do not add
   `pysail`'s `requires_dist`.

3. **Add a `"Sail"` label** to `connection_label()` in `R/connect-utils.R`.

4. **Add `R/connect-sail.R`:**

   ```r
   #' @export
   spark_connect_method.spark_method_sail <- function(x, method, master,
                                                      spark_home, config = NULL,
                                                      app_name, version = NULL,
                                                      hadoop_version, extensions,
                                                      scala_version, ...) {
     # abort if master is missing, or is "local" (added in Phase 6)
     # if version is NULL, resolve both versions up front with sail_versions()
     args <- list(...)
     envname <- use_envname(
       backend = "sail",
       main_library = "pyspark-client",
       backend_version = version,
       main_library_version = sail_versions(version)$main_library_version,
       envname = args$envname,
       messages = TRUE,
       match_first = TRUE,
       python_version = args$python_version
     )
     if (is.null(envname)) {
       return(invisible())
     }
     pyspark <- import_check("pyspark", envname)
     conn <- pyspark$sql$SparkSession$builder$remote(master)
     initialize_connection(
       conn = conn,
       master_label = glue("Sail - {master}"),
       con_class = "connect_sail",
       method = method,
       config = config
     )
   }

   setOldClass(c("connect_sail", "pyspark_connection", "spark_connection"))
   ```

5. **Hide the `install_sail()` hint** in `use_envname()` until Phase 5.

6. **Run `devtools::document()`**, including roxygen for the renamed
   arguments.

## Phase 3: manual testing

Start a server with `sail spark server`. Write the answers into this file.

- Connect, `copy_to()`, a `dplyr` pipeline, `collect()`,
  `dbGetQuery(sc, "select 1 as n")`, `spark_disconnect()`.
- Which `pyspark_config()` entries does Sail accept?
- Does `session$version` work? If not, `initialize_connection()` shows a
  Databricks error message.
- Which catalog statements in `R/ide-connections-pane.R` does Sail not
  support?
- Does version matching work for `pysail` 0.x versions?
- Do these work: `catalog$tableExists()`, `catalog$dropTempView()`,
  `createDataFrame()`, `createOrReplaceTempView()`, backtick identifiers,
  `persist()` with `MEMORY_AND_DISK`?
- The environment has `pyspark-client` at the pinned version and `pysail`
  at `backend_version`, and no `pyspark`, `databricks-sdk`, or
  `google-api-python-client`.
- A missing pin shows a message; a found pin shows nothing.

### Results

Tested on 2026-09-28 against `pysail` 0.7.1 and `pyspark-client` 4.2.0.

**Blocking issues:**

- **`pyspark-client` exits Python on import from R.** `getOrCreate()` imports
  `pyspark.sql.connect`, whose `check_dependencies()` treats a `__main__`
  with no `__spec__`, `__file__`, or `sys.ps1` as a doctest run. It then
  imports `pyspark.testing.connectutils`, which imports
  `pyspark.testing.sqlutils`, which runs `_find_spark_home()` at import and
  calls `sys.exit(-1)`. This happens in interactive R and in `Rscript`. The
  user sees "Could not find valid SPARK_HOME" and advice to install PySpark.
  Setting `SPARK_HOME` to any directory avoids it. Full `pyspark` does not
  have the problem, since it ships a Spark distribution. Done: the Sail
  method wraps `import_check()` in `withr::with_envvar()`, keeping the
  user's `SPARK_HOME` or using `tempdir()`. It has to be set when Python
  starts, since Python does not see later changes, so it only works if
  Python starts at the first Sail connection.
- **The Sail server needs `pyspark` or `pyspark-client` in its own
  environment.** Without it, `session$version` fails with "failed to get
  PySpark version: No module named 'pyspark'". Done: non-Databricks
  connections no longer show the Databricks error message. Still open: for
  servers started by the user, the Phase 9 docs need to cover this, for
  example `uv tool install pysail --with pyspark-client`.

**Results, with `SPARK_HOME` set and `pyspark-client` in the server's
environment:**

- Connect, `copy_to(memory = FALSE)`, a `dplyr` pipeline, `collect()`,
  `dbGetQuery(sc, "select 1 as n")`, backtick identifiers, and
  `spark_disconnect()` work.
- `session$version` returns `4.2.0`.
- Sail accepts all three `pyspark_config()` entries, and reads them back.
- `show catalogs` (`sail`, `system`), `show databases in`, and
  `show tables in` work. Temp views are filtered out, so the pane shows no
  tables (see "After implementation"). Column lists and previews fail with
  `` `sail`.`default`.`mtcars` `` but work with the name alone.
- `catalog$tableExists()`, `catalog$dropTempView()`, `createDataFrame()`,
  and `createOrReplaceTempView()` work. `persist()` is accepted but is a
  no-op in Sail.
- `CACHE TABLE` in every form, `catalog$cacheTable()`, `isCached()`, and
  `clearCache()` fail with `UnsupportedOperationException`. Done:
  `copy_to()` and `spark_read_*()` abort on `memory = TRUE`, `compute()`
  aborts, and `copy_to(memory = FALSE)` names the temp view after the table.
- `checkpoint()` needs `execution.checkpoint.path` set on the server.
- Version matching works for 0.x: `0.7` and `0.7.1` match
  `r-sparklyr-sail-0.7`.
- The environment has `pyspark-client` 4.2.0 and `pysail` 0.7.1, and no
  `pyspark`, `databricks-sdk`, or `google-api-python-client`.
- A missing pin shows a message; a found pin shows nothing.

## Phase 4: fixes from manual testing

- Set the `config` default.
- Make the `session$version` error depend on the connection class, if needed.
- Pass `misc` overrides to `initialize_connection()` for catalog statements,
  as `R/connect-snowflake.R` does.
- Add `is_sail()` only if a case needs it.

## Phase 5: `install_sail()`

1. Add `install_sail()` like `install_pyspark()`, with `backend = "sail"`,
   `main_library = "pyspark-client"`, and `sail_versions()` for the versions.
   Document under `@rdname install_pyspark`.
2. Turn the install hint back on.
3. Check that `build_job_code()` (`R/python-install.R`) passes the new
   argument names.

Done when `install_sail()` creates `r-sparklyr-sail-0.7` with the right
packages, a second connect finds it by exact match, and `as_job = TRUE`
works in RStudio.

## Phase 6: start a local Sail server

1. **Start the server on `master = "local"`** in
   `spark_connect_method.spark_method_sail()`:
   - `import_check("pysail.spark", envname)`, then
     `SparkConnectServer(ip = "127.0.0.1", port = 0L)` and `$start()`.
     Port `0` picks a free port.
   - Read the port from `$listening_address` and connect to
     `sc://localhost:{port}`.
   - Keep the server object in the connection, for example as `sc$server`.
     `initialize_connection()` needs a new argument for it.
   - Set `master_label` to `"Sail - local"`.

2. **Add `spark_disconnect.connect_sail()`.** Stop the session, then call
   `$stop()` on the server if `sc` has one. sparklyr's
   `spark_disconnect.spark_connection()` calls this method and hides any
   errors, so report a failed stop with a cli warning.

Done when `spark_connect("local", method = "sail")` works, two local
connections in one session get different ports, and `spark_disconnect()`
stops the server (`$running` is `FALSE`).

## Phase 7: tests and CI

1. Add a `SAIL_VERSION` variable to `tests/testthat/helper-init.R`. When it
   is set, the tests run against Sail at that version. When it is not set,
   they run against Spark as today. If both `SAIL_VERSION` and
   `SPARK_VERSION` are set, use Sail and show a message that `SPARK_VERSION`
   is ignored. For Sail:
   - `use_test_connect_start()` runs `install_sail()` and starts nothing.
   - `use_test_spark_connect()` connects with `master = "local"` and
     `method = "sail"`, without the `PYSPARK_*` variables.
2. Add `skip_if_sail()` and use it in the ML tests
   (`test-ml-*.R`), `test-sparklyr-spark-apply.R`, and tests that only apply
   to Spark, such as `test-zzz-spark-connect.R`.
3. Add `tests/testthat/test-sail-connect.R`, like
   `test-zzz-spark-connect.R`. Skip unless `SAIL_VERSION` is set.
4. Add `.github/workflows/sail-tests.yaml`, based on `spark-tests.yaml`:
   no Java, and one matrix line for now (Sail 0.7, Python 3.12). Add more
   Sail or Python versions later if needed.

Done when `devtools::test()` passes with and without `SAIL_VERSION` (ML and
`spark_apply()` tests skip on Sail), the workflow passes, and
`devtools::check()` is clean.

## Phase 8: `spark_apply()`

Sail runs `mapInPandas()` and `applyInPandas()` with `rpy2`, on a local
server and on a remote one. On a local server, the R code runs inside the
user's R session, on Sail's threads. Tested by hand with hand-written UDFs:
correct results over 8 partitions and 8 groups, 3 runs, no crashes.

1. **Add Sail versions of the Python UDF files** in `inst/udf/`
   (`udf-map.py`, `udf-apply.py`, and the two `-context` files), and have
   `spark_apply()` use them for Sail. Every `rpy2` call, including
   `robjects.r(...)`, goes inside `with localconverter(...)`: `rpy2` keeps its
   conversion rules per thread, and Sail's threads have none. The R UDF
   files are shared, and the UDF code runs the same way as on Spark.
2. **Add an internal `supported_cache()` method**, `TRUE` by default and
   `FALSE` for Sail. `spark_apply()` calls `compute()` on tables that are not
   plain tables only if caching is supported, and uses a temp view
   otherwise.
3. **Install `rpy2` by default** in `install_sail()`, and in the temporary
   environment declared at connect time.
4. **Clearer error for a Python version mismatch** with a remote server, if
   it is quick to do. Sail reports "Python version used to compile the UDF
   (3.11) does not match the Python version at runtime (3.13)".
5. **Test by hand** `arrow_max_records_per_batch`, `barrier`, `context`, and
   `group_by`. Ask before adding formal tests for them.
6. **Remove `skip_if_sail()`** from `test-sparklyr-spark-apply.R`.

Out of scope: `tune_grid_spark()`. It uploads its data with
`addArtifact(file = TRUE)`, which Sail does not support ("handle add
artifacts"), and reads it with `SparkFiles`, which `pyspark-client` does not
have. `test-tune-grid.R` stays skipped on Sail.

Done when `test-sparklyr-spark-apply.R` passes on Sail, `spark_apply()`
works on a local and on a remote Sail server, and the Spark tests still
pass.

## Phase 9: docs and NEWS

- Mark the whole Sail back-end as experimental in NEWS.
- NEWS bullets for the `sail` method, the `version` split, `install_sail()`,
  local Sail connections, `spark_apply()` on Sail, and the Sail CI workflow.
- Call out the known issues in NEWS: with a local server, `spark_apply()`
  runs R code inside the user's R session on Sail's threads, so a crash in
  the UDF can end the session, and UDF code can change the session's global
  environment.
- README or vignette: run `install_sail()`, then
  `spark_connect("local", method = "sail")`. Also show connecting to a
  remote server with `sc://`, and what the server needs: `pyspark-client`,
  plus `rpy2`, R, and the same Python version for `spark_apply()`.
- List the configs and Connections pane features that work.
- Say that ML functions and `tune_grid_spark()` are not supported on Sail.

## After implementation

Changes for all back-ends, found while working on Sail.

1. **Show named temp views in the Connections pane.** `catalog_python()` in
   `R/ide-connections-pane.R` drops every temp view
   (`tables[!tables$isTemporary, ]`), so tables from `copy_to()` never show,
   on Spark or Sail.
   - Drop only temp views whose names start with `temp_prefix()`
     (`sparklyr_tmp_`), which are pysparklyr's intermediate results.
   - In `rs_get_table()`, address temp views by name alone, since
     `` `catalog`.`schema`.`view` `` usually fails for temp views on Spark.
2. **Name the temp view for Snowflake.** `copy_to(memory = FALSE)` now
   names the temp view after the table on Spark, Databricks, and Sail, but
   not Snowflake. Check on Snowflake:
   - Whether `createOrReplaceTempView(name)` works on a Snowpark DataFrame,
     and whether `tbl(sc, "mtcars")` finds it, since Snowflake upper-cases
     unquoted names.
   - Whether `catalog$tableExists()` works on Snowpark, so the `overwrite`
     check can run. If not, Snowflake needs its own existence check.
3. **Drop temp views in `dbRemoveTable()` for the other back-ends.**
   sparklyr's `dbRemoveTable()` sends `DROP TABLE`, which Sail rejects for
   temp views, so Sail has its own method in `R/connect-sail.R` that tries
   `catalog$dropTempView()` first. Check whether Spark Connect, Databricks,
   and Snowflake should use the same approach, since `pivot_longer()` and
   `spark_read_*(overwrite = TRUE)` drop temp views this way.

## Open questions

None.
