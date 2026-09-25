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
   no Java, matrix of `SAIL_VERSION` and Python (3.10 to 3.14) versions.

Done when `devtools::test()` passes with and without `SAIL_VERSION` (ML and
`spark_apply()` tests skip on Sail), the workflow passes, and
`devtools::check()` is clean.

## Phase 8: docs and NEWS

- NEWS bullets for the `sail` method, the `version` split, `install_sail()`,
  local Sail connections, and the Sail CI workflow.
- README or vignette: run `install_sail()`, then
  `spark_connect("local", method = "sail")`. Also show connecting to a
  remote server with `sc://`.
- List the configs and Connections pane features that work.
- Say that ML functions and `spark_apply()` are not tested with Sail.

## Open questions

None.
