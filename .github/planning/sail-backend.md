# Plan: add a Sail back-end to pysparklyr

[Sail](https://github.com/lakehq/sail) is a Rust engine that speaks the Spark
Connect protocol. Its Python package, `pysail`, can start a Spark Connect
server without a JVM.

Read "Background" at the bottom before starting. Everything below rests on
facts checked against `pysail` 0.7.1 and `pyspark-client` 4.2.0, and several
of the decisions look arbitrary without them.

## Phases

1. **The `sail` connection method.** Connect to a Sail server the user
   started themselves. Split into 1a code, 1b manual testing, 1c changes from
   what 1b found, 1d docs and NEWS.
2. **Automated tests and CI.** An engine switch in the test helpers, plus a
   `sail-tests.yaml` workflow.
3. **`install_sail()`.** A managed environment for the back-end.
4. **Starting a local Sail server.** Not committed to.

## Decisions already made

- `spark_connect(method = "sail")` will **not** start a server. The user
  passes a `master` such as `sc://localhost:50051`.
- The client library is `pyspark-client`, not `pyspark`.
- `main_library` stays a single slot and is `pyspark-client`. `pysail` is read
  from PyPI for its version pin but is never installed in the connection
  environment.
- `version` splits into `backend_version` and `main_library_version`, because
  Sail is the first back-end where those are different numbers.

---

## Phase 1: the `sail` connection method

### Goal

```r
library(sparklyr)
sc <- spark_connect(method = "sail", master = "sc://localhost:50051")
copy_to(sc, mtcars)
tbl(sc, "mtcars") |> dplyr::summarise(n = n())
```

Split into four sub-phases. 1a and 1b are the bulk of the work; 1c exists
because several decisions here cannot be made without a live Sail server.

---

### Phase 1a: code changes

Everything that can be written without a Sail server in front of us.

**1. Split `version` in `use_envname()` and `python_requirements()`.**

This is the root problem, and it is not Sail-specific. `version` silently does
two jobs: it names the environment and drives user-facing messages, and it
pins the Python library. Every back-end so far has had those be the same
number by construction, so the conflation never showed. DBR 16.1 pairs with
`databricks-connect` 16.1 because Databricks ships a full PySpark wrapper
under its own version. Sail does not: `pysail` 0.7 pairs with
`pyspark-client` 4.2.

Replace `version` with `backend_version` and `main_library_version`, the
second defaulting to the first. Existing back-ends pass one number and behave
exactly as they do today.

Classified by intent, in `use_envname()`:

| line | use | becomes |
|---|---|---|
| 46 | `install_{backend}()` hint text | `backend_version` |
| 50-51 | `version_prep()` into the env name | `backend_version` |
| 56, 131 | `install_ver` in the install prompt | `backend_version` |
| 61-65 | compare against latest on PyPI, resolve `"latest"` | `main_library_version` |
| 111 | "Library {con_label} version ... is not yet available" | see below |
| 144 | passed to `install_{backend}()` | `backend_version` |
| 169 | passed to `python_requirements()` | both |

And in `python_requirements()`:

| line | use | becomes |
|---|---|---|
| 213-214 | `databricks_dbr_python()`, branches on `>= "16.0"` | `backend_version` |
| 219 | `library_version` for the PyPI lookup | `main_library_version` |
| 227-228, 231-233 | normalising and widening the pin | `main_library_version` |
| 248 | `paste0(main_library, "==", version)` | `main_library_version` |

Three places need a decision, not a rename:

- **Lines 28-41**, the "no version given" path, resolves the version from
  `main_library`'s latest release on PyPI. Under the split that yields a
  `main_library_version` with no `backend_version` to name the environment
  with. For Sail the resolution has to run the other way: take the latest
  `pysail`, then derive the client version from it. This needs to be back-end
  aware.
- **Lines 67-70** rename the environment to `{env_base}{latest_ver}` when the
  requested version outruns the newest library release. That branch exists
  only because the two numbers share a scale, which is the assumption we are
  removing. It is meaningful for Databricks and meaningless for Sail. Guard it
  so it only runs when `main_library_version` defaults to `backend_version`.
- **Lines 104-113**, the `install_recent` branch, breaks for Sail rather than
  just reading oddly. It is reached when `compareVersion(latest_ver, version)`
  at line 65 is not `1`, meaning the requested version is at or beyond the
  newest published release, and it prints "Library {con_label} version
  {version} is not yet available". For Sail the version comes from a
  published `pysail` pin, so it is always a real release, and when the pin is
  the newest client, which it is today, `compareVersion` returns `0` and the
  message fires claiming an available version is unavailable. It only fires
  with `match_first = TRUE` and another `r-sparklyr-sail-*` environment
  present, which the Sail method will hit, since it copies
  `match_first = TRUE` from `connect-spark.R`. Skip the branch
  when the version was derived from a pin rather than supplied by the user.

**2. Update every caller.**

Renaming the argument breaks all six `use_envname()` call sites, plus the
install chain. None of them change behaviour: each passes a back-end version
today, so each becomes `backend_version` and picks up the default
`main_library_version`. Listing them so none is missed:

| caller | passes | becomes |
|---|---|---|
| `R/connect-spark.R:24` | `version = version` | `backend_version` |
| `R/connect-databricks.R:49` | `version = version` | `backend_version` |
| `R/connect-snowflake.R:21` | `version = version %||% "latest"` | `backend_version` |
| `R/start-stop-service.R:48` | `version = version` | `backend_version` |
| `R/deploy.R:276` | `version = version` | `backend_version` |
| `R/python-install.R:214` | `version = ver_name` | see below |
| `R/python-use-envname.R:166` | `version` to `python_requirements()` | both |

`R/python-install.R:214` is the one that is not a rename. `install_environment()`
passes `ver_name`, which is derived from `python_library_info(main_library, version)`
a few lines up, so it names the environment from the **library** version. That
is the same conflation as in `use_envname()`, in a third place.

**3. Fold the two package lists together.**

`install_environment()` at `R/python-install.R:177-232` and
`python_requirements()` at `R/python-use-envname.R:213-253` are the same
logic written twice. Both resolve the library version through
`python_library_info()`, fall back to `version_prep()` and a `.*` suffix,
build `paste0(main_library, "==", version)`, and append
`pysparklyr_env$ml_libraries` under `add_torch && install_ml`. The version
resolution block is line-for-line identical.

They diverge in one way that matters: `python_requirements()` prefers the
library's `requires_dist` from PyPI and only falls back to the hardcoded list,
while `install_environment()` **always** uses the hardcoded list. That list
is Databricks-flavoured, so without folding, `install_sail()` in Phase 3 would
put `google-api-python-client` and `databricks-sdk` into a Sail environment.
Folding is not cleanup here; Phase 3 is wrong without it.

Smaller differences to preserve: `python_requirements()` appends `"pip"` and
carries the `databricks_dbr_python()` branch; `install_environment()` computes
`add_torch` itself by comparing `ver_name` against `ml_version`, and needs
`ver_name` for the environment name, which `python_requirements()` does not
return.

Suggested shape: extract the shared resolution block into a helper returning
`version`, `ver_name`, and `python_version`. `python_requirements()` calls it
and builds the package list. `install_environment()` calls
`python_requirements()` for packages and `python_version`, keeps computing
`add_torch`, and takes `ver_name` from the helper for naming.

This also gives the `version` split from work item 1 a single home. Right now
the conflation lives in three places; after this it lives in one.

**4. Resolve the client version from Sail, as a heuristic.**

`backend_version` is Sail's, so something has to produce
`main_library_version` **before** `use_envname()` is called, since it is an
argument to it. Call it `sail_client_version()`.

Sail 0.7.1 pins `pyspark-client==4.2.0`, so read the pin off `pysail`'s
metadata rather than floating the client to newest and risking an old engine
against an untested protocol.

The steps:

1. **Query `pysail` on PyPI.** `python_library_info("pysail", version)`
   already does this, via the versioned endpoint that `query_pypi()` builds at
   `R/python-install.R:412`. Partial versions work: `pysail/0.7` returns
   `0.7.0`, the same way `pyspark/4.2` returns `4.2.0`. If the user gave no
   version, the unversioned endpoint gives the newest release, which becomes
   `backend_version` too.
2. **Find the pin.** Scan **all** of `requires_dist` for the distribution
   name, normalising case and `-`/`_`. Do not look only in the `test` extra,
   where it lives today; it could be renamed or promoted to a real
   dependency.
3. **Resolve the pin to a version.** It is `==4.2.0` today. If it becomes a
   range like `>=4.2,<4.3`, take the newest matching `pyspark-client`
   release.
4. **Return `NULL`** if the pin cannot be found, and wrap the whole thing in
   `try()` so an unreachable PyPI returns `NULL` rather than erroring.

Emit a cli message **only when the result is `NULL`**. The pinned path stays
silent, so a future mismatch surfaces as something a user can report rather
than as noise on every connect.

Offline users are not stranded by a `NULL`. They pass either a Sail version
matching an existing `r-sparklyr-sail-*` environment, or an explicit
`envname`.

**Do not force the lookup early.** `use_envname()` returns at line 24 when
`envname` is supplied. On an exact environment match (line 97) it does not
return, but the only reads of the library version, lines 58-72 and 166, sit
behind `!match_exact` or the `unavailable`/`latest` names. Passing
`main_library_version = sail_client_version(version)` as an argument means R
evaluates it lazily, so neither path makes a network call. That only holds
while nothing new reads `main_library_version` outside those guards.

**5. Add a `connection_label()` branch.**

`R/connect-utils.R` maps a back-end or method name to a display label. Add one
returning `"Sail"`.

**6. Add `R/connect-sail.R`.**

Model it on `R/connect-spark.R`, the shortest of the three existing methods:

```
#' @export
spark_connect_method.spark_method_sail <- function(x, method, master,
                                                   spark_home, config = NULL,
                                                   app_name, version = NULL,
                                                   hadoop_version, extensions,
                                                   scala_version, ...) {
  # master is required; abort with a clear message if missing
  # backend_version is pysail's (e.g. "0.7"); main_library_version is
  # derived from it by sail_client_version(), see work item 4
  args <- list(...)
  envname <- use_envname(
    backend = "sail",
    main_library = "pyspark-client",
    backend_version = version,
    main_library_version = sail_client_version(version),
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
    config = config # see work item 7
  )
}

setOldClass(c("connect_sail", "pyspark_connection", "spark_connection"))
```

The import is `pyspark`, the module name that `pyspark-client` provides.

`use_envname()` has no `...`, so the arguments are picked out of `...` by
name, as `R/connect-spark.R` does. Forwarding `...` directly would fail on any
extra argument.

**7. Start `config` at `NULL`.**

`initialize_connection()` applies each config entry with `session$conf$set()`.
`pyspark_config()` sets three `spark.sql.*` options, and whether Sail accepts
them is unknown. Default `config` to `NULL` for now, which skips the loop entirely, and pass
the argument through so a user-supplied `config` still applies. Phase 1b
decides what the default becomes.

**8. Suppress the install hint.**

`use_envname()` builds a `pysparklyr::install_{backend}()` hint from the
back-end name, so on the Sail path it will suggest `install_sail()`, which
does not exist until Phase 3. Connecting still works, because the
`py_require()` path declares an ephemeral environment, but the suggestion is
dead. Suppress it for `sail` and restore it in Phase 3.

**9. Run `devtools::document()`.**

So `S3method(spark_connect_method,spark_method_sail)` lands in `NAMESPACE`.
Documentation prose waits for 1d, but the roxygen for the renamed version
arguments has to be written here or `devtools::check()` will complain.

---

### Phase 1b: manual testing

Against a real Sail server, started with `sail spark server`. Record every
answer in this document as it is found; several later decisions depend on
them.

**Connection and data**

- `spark_connect(method = "sail", master = ...)` returns a connection.
- `copy_to()`, a `dplyr` pipeline, `collect()`, `spark_disconnect()`.
- `dbGetQuery(sc, "select 1 as n")` returns a one-row frame.

**Open questions to close**

- Add each `pyspark_config()` entry back one at a time. Which does Sail
  accept?
- What does `session$version` return? `initialize_connection()` calls it and
  routes failures to `databricks_dbr_error()`, whose message names Databricks
  and would be wrong here.
- Which catalog statements does `catalog_python()` rely on that Sail spells
  differently, or does not support? `show catalogs`,
  `show tables in {schema}`, and the rest in `R/ide-connections-pane.R`.
- Does `use_envname()`'s version matching behave sensibly for `pysail`'s 0.x
  versions?
- Does Sail support the operations the `copy_to()` and `compute()` paths
  rely on? The `is_snowflake()` branches in `R/dplyr.R` exist because
  Snowpark's `Session` is not a Spark Connect client, so Sail takes the same
  path as `connect_spark` and needs no branch of its own. What is untested is
  whether the Sail *server* implements what that path calls:
  `catalog$tableExists()` and `catalog$dropTempView()`,
  `createDataFrame()` from an R data frame, `createOrReplaceTempView()`,
  backtick-quoted identifiers via `dbQuoteIdentifier()`, and `persist()` with
  `StorageLevel$MEMORY_AND_DISK`. An `is_sail()` predicate is only warranted
  if one of these comes back unsupported.

**Environment and regression**

- The environment contains `pyspark-client` at the version Sail pins, and
  neither `pysail` nor `databricks-sdk` nor `google-api-python-client`.
- The environment never contains both `pyspark` and `pyspark-client`.
- The fallback path warns when the `pysail` pin cannot be found; the pinned
  path says nothing.
- The three existing back-ends resolve the same environment names and
  package lists as before the `version` split and the package-list fold.
  This is the riskiest part of 1a, since it touches every back-end.

---

### Phase 1c: code changes from 1b findings

Cannot be written in advance. Expected shape:

- Set the real `config` default from what Sail accepted.
- Make the `session$version` error branch aware of the connection class, if
  1b showed it can fail.
- Supply `misc` overrides to `initialize_connection()` for whichever catalog
  statements Sail spells differently, as the Snowflake method does.
- Add an `is_sail()` predicate only if 1b produced a case that needs one.

Everything here is verified by hand. The automated suite is Phase 2.

---

### Phase 1d: docs and NEWS

- NEWS.md bullet for the `sail` method, and a separate one for the `version`
  split if it changes any user-facing argument.
- README or vignette section covering the two steps: start a server with
  `sail spark server`, then connect. Since `pysail` is not in the connection
  environment, show how to install it separately, for example with
  `uv tool install pysail`.
- Record the 1b answers that users need: which configs apply, what the
  Connections pane supports.
- Say plainly that ML and `spark_apply()` are untested against Sail.

### Expected to be out of scope

The ML functions (`ml_*`, `ft_*`) and `spark_apply()` are untested against
Sail. Untested, not known broken. They are out of scope here because nothing
in this phase covers them, not because we have established they fail.

If it matters later, the two things to actually check are whether Sail
implements the MLlib surface the `ml_*` functions call, and whether
`spark_apply()` has an `rpy2` equivalent on the Sail side. Until someone runs
that, the honest wording in the docs is "not tested".

---

---

## Phase 2: automated tests and CI

### Goal

`devtools::test()` runs the existing suite against either a JVM Spark Connect
server or a Sail server, chosen by one environment variable, and a
`sail-tests.yaml` workflow runs the Sail side on every push.

### Work items

**1. Add the engine switch to the test helpers.**

`tests/testthat/helper-init.R` already reads `SPARK_VERSION`,
`SCALA_VERSION`, and `PYTHON_VERSION` from the environment, so this follows
the established pattern. Add something like `SPARK_ENGINE`, defaulting to
the current behaviour when unset.

Two functions branch on it:

- `use_test_connect_start()` at line 50 starts the JVM service. For Sail it
  does nothing, because the workflow starts the server itself (work item 3).
- `use_test_spark_connect()` at line 87 calls `spark_connect()` with
  `method = "spark_connect"`, `master = "sc://localhost"`, and a `version`.
  For Sail it passes `method = "sail"` and the Sail server's address.

Note the Sail branch also drops the `PYSPARK_PYTHON` and
`PYSPARK_DRIVER_PYTHON` environment variables those helpers set, since they
exist for the JVM launcher.

**2. Add `tests/testthat/test-sail-connect.R`.**

Follow `test-zzz-spark-connect.R`, which calls the method function directly
rather than going through `spark_connect()`. Skip unless a Sail server is
reachable, in the style of `skip_if_not_databricks()` in
`helper-databricks.R`.

**3. Add `.github/workflows/sail-tests.yaml`.**

Model it on `spark-tests.yaml`, which is already a matrix driven by env
vars. Differences:

- No `setup-java` step. That is the point of Sail.
- No `SPARK_VERSION`, `SCALA_VERSION`, or `HADOOP_VERSION`. The matrix
  carries a `pysail` version and a Python version instead.
- Install `pysail` and start the server as a workflow step, backgrounded, and
  wait for the port before running the suite.
- Set the `SPARK_ENGINE` variable so the helpers take the Sail branch.

Decide the matrix: at minimum the newest `pysail`, and whichever Python
versions match its `requires_python` of `>=3.10,<3.15`.

**4. Add a snapshot test for the existing back-ends.**

Phase 1a changes `use_envname()` and `python_requirements()` for every
back-end. 1b checks by hand that environment names and package lists are
unchanged; this locks that in so the next change to those functions cannot
quietly break Databricks or Snowflake.

### Verification

- `devtools::test()` with the variable unset behaves exactly as it does
  today.
- `devtools::test()` with it set to Sail runs the suite against Sail, with
  ML and `spark_apply()` tests skipping rather than failing.
- `sail-tests.yaml` passes on a pull request.
- `devtools::check()` is clean.

## Phase 3: `install_sail()`

### Why it is separate

Phase 1 connects without it. The environment machinery falls back to
`py_require()`, which declares an ephemeral environment, so nothing is
blocked. What is missing is a managed, named environment and a working
install hint. That is a self-contained piece of work with its own decision
about `pysail`, and bundling it into Phase 1 would mean shipping nothing until
both are done.

### Work items

**1. Add `install_sail()`.**

Follow `install_pyspark()` in `R/python-install.R`. It takes `version`,
`envname`, `python_version`, and `as_job`, and forwards to `install_as_job()`
and `install_environment()` with `backend = "sail"` and
`main_library = "pyspark-client"`.

`version` is Sail's, matching the connect method, so it runs through the same
`sail_client_version()` resolver from Phase 1 to produce the library version.
Document both meanings in the roxygen block, under `@rdname install_pyspark`.

**2. Decide whether `pysail` goes in the environment.**

It is not needed to connect. It *is* needed to start a server, which is the
user's job in Phase 1 and pysparklyr's job in Phase 3. Adding it means the
`sail` environment carries a 52 MB wheel that the connect path never imports.
Leaving it out means the docs tell users to install it separately.

Note the environment is named from `backend_version`, so `r-sparklyr-sail-0.7`
tracks `pysail` either way. Including it later does not force a rename.

**3. Check `build_job_code()`.**

`install_as_job()` writes R code to a temp file and runs it as an RStudio job.
Confirm the new argument names survive that round trip, since the generated
code at `R/python-install.R:495` names arguments explicitly.

### Verification

- `install_sail()` creates `r-sparklyr-sail-0.7` containing `pyspark-client`
  at the pinned version and its client dependencies, with no
  `databricks-sdk` and no `google-api-python-client`. This only holds if the
  Phase 1a package-list fold landed.
- The install hint printed by `use_envname()` names a function that exists and
  a version the user recognises as Sail's.
- A second `spark_connect(method = "sail")` finds the environment by exact
  match rather than re-declaring requirements.
- `install_sail(as_job = TRUE)` works in RStudio.

---

## Phase 4 (not committed to): starting a local Sail server

### Why this is deferred

`spark_connect_service_start()` and `spark_connect_service_stop()` work by
running shell scripts. Start fires `start-connect-server.sh` and returns. Stop
fires `stop-connect-server.sh`, a separate command that finds and kills the
server on its own. The two calls share no state.

The reticulate approach in `temp-sail.R` does not work that way.
`SparkConnectServer` is a Python object living in the R session. Stopping it
means calling `$stop()` on that same object, so the start call has to hand
something to the stop call, and the existing functions have no way to do that.

### Sketch of the options

- **The `sail` CLI through processx.** A foreground command, so this is close
  to how the JVM path already works and an `engine` argument would fit. Two
  differences from the Spark scripts: no `stop` subcommand, so stopping means
  killing the process handle, which processx does; and `--port` defaults to a
  fixed 50051 rather than picking a free one, so we set the port.
- **A separate pair of functions.** `sail_service_start()` and
  `sail_service_stop()` around the reticulate object, held in
  `pysparklyr_env`. Honest about being a different lifecycle, at the cost of
  two more exported names.
- **An `engine` argument, with state.** One pair of functions, with the server
  object in `pysparklyr_env` and the stop path branching on what is there. One
  name to learn, two behaviours underneath.
- **Auto-start on connect.** `spark_connect(method = "sail")` with no `master`
  starts a server and connects, reducing the local workflow to one line. Needs
  `spark_disconnect()` to know whether to stop a server it started.

Every route needs `pysail` installed somewhere, which is the Phase 3 decision.

---

## Open questions

### Phase 1

All of them need a live Sail server, so they are listed as the work of Phase
1b rather than repeated here.

### Phase 2

- What is the variable called, and what values does it take? `SPARK_ENGINE`
  with `spark` and `sail` is a guess, not a decision.
- Does the workflow install `pysail` with `uv`, `pip`, or the managed
  environment once Phase 3 exists?

### Phase 3

- Does `pysail` go in the environment, or do the docs point users elsewhere?

### Phase 4

- Nothing outstanding on the mechanics. The question is which of the four
  shapes to take.

---

## Background

Facts read from `pysail` 0.7.1, `pyspark-client` 4.2.0, and their sources on
PyPI. These drive the decisions above.

### Sail ships no Python client

`pysail.spark` exports exactly one name, `SparkConnectServer`. `pysail.flight`
exports `FlightSqlServer`. That is the whole Python surface. Nothing in the
package has a `SparkSession` or a `.remote()`.

Sail's own test suite connects with `from pyspark.sql import SparkSession`,
which is why it pins `pyspark-client==4.2.0` in its `test` extra.

So the shape is inverted from the other three back-ends: `pysail` runs a
server and is never imported to connect, while the client package has nothing
to do with the engine.

### `pysail` declares no runtime dependencies

Its `pyproject.toml` has `dependencies = []`. Everything sits behind the
`jdbc`, `mcp`, `test`, and `vortex` extras. `requires_python` is
`>=3.10,<3.15`.

This matters because `python_requirements()` reads `requires_dist` from PyPI,
strips the `; extra == "..."` marker, and treats the result as a hard
requirement. Pointed at `pysail` it would install the entire test suite
(`pytest`, `moto`, `testcontainers`, `duckdb`, `pyiceberg`, and the rest)
while still missing every client library. Pointing `main_library` at
`pyspark-client` instead avoids this entirely.

### Every existing back-end versions its client under its own number

`databricks-connect` declares `databricks-sdk` itself and ships a full PySpark
wrapper, so DBR 16.1 pairs with `databricks-connect` 16.1. The back-end
version and the library version are the same number by construction. The same
holds for `pyspark`, where they are the same thing.

Sail breaks this. `pysail` 0.7 pairs with `pyspark-client` 4.2, and the two
version lines are unrelated. That is the root of the problem Phase 1 has to
solve, and it is why `version` cannot keep doing two jobs.

### `pyspark-client` is the right client

It is the pure-Python Spark Connect client carved out of the Spark release.

- It ships every module pysparklyr imports: `storagelevel`, `sql/types`,
  `sql/functions/`, and the full `ml/` and `ml/connect/` trees.
- It is 1.7 MB against full PySpark's 450 MB, which is the point of using an
  engine that needs no JVM.
- Its `requires_dist` is exactly the client set: `pandas`, `pyarrow`,
  `grpcio`, `grpcio-status`, `googleapis-common-protos`, `zstandard`, `numpy`,
  `pyyaml`. Note `googleapis-common-protos`, not the
  `google-api-python-client` that `temp-sail.R` asks for.

Two caveats:

- **No `SparkFiles`.** There is no `pyspark/core/`, and `__init__.py` imports
  `SparkFiles` from `pyspark.core.files` behind `if not is_remote_only()`. The
  call sites in `R/tune-grid.R` (lines 323-324 and 378) are live:
  `R/tune-grid.R:94` rewrites `debug <- TRUE` to `debug <- FALSE` before the
  code is shipped. But that code runs on the workers inside `spark_apply()`,
  not in the client environment, so the client's missing `SparkFiles` does
  not affect it. Whether Sail's workers provide it falls under the untested
  `spark_apply()` surface.
- **It collides with `pyspark`.** Both distributions install a top-level
  `pyspark/` package. A Sail environment must contain one or the other, never
  both. The module is imported as `pyspark` either way.

### The two packages are versioned in lockstep

Same version strings, published the same day: 4.2.0 on 2026-07-14, 4.1.3 and
4.0.4 on 2026-07-15. `pyspark-client` starts at 4.0.0 and has no 3.x line, so
it cannot replace `pyspark` in the existing back-ends, where `use_envname()`
still matches 3.5 clusters. That is fine here, since Sail does not implement
Spark 3.5 anyway.

### Server details, for Phase 4

`SparkConnectServer(ip = "127.0.0.1", port = 0)`, with `port = 0` documented
as a random port. Also `start(background = TRUE)`, `stop()`, and the
`listening_address` and `running` properties.

The CLI is `sail spark server --ip <ip> --port <port>`, port defaulting to
50051, running in the foreground. There is no `stop` subcommand, unlike
Spark's `stop-connect-server.sh`.

### The working prototype

`temp-sail.R` at the repo root is the proof of concept. Only its last step is
Phase 1 material:
`pyspark_sql$SparkSession$builder$remote("sc://localhost:<port>")$getOrCreate()`.
The rest is for Phase 4.
