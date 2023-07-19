## Progress

### Installation

-   [x] Helper function to install Python and needed libraries

### Connectivity and Session

-   [x] Initial connection routines
-   [x] Spark Connect connectivity
-   [ ] Initiate Spark Connect when creating new connection, similar to "local" (Maybe)
-   [ ] Fail when user changes from one connection to another in the same R/Python session

### RStudio Integration

-   [x] Initial Connection contract works
-   [x] Implement and integrate custom three layer (catalog, schema, table) structure for navigation
-   [x] Implement column preview for `pyspark_connection`. Mainly because the current way does not allow for a three layer structure.
-   [x] Implement "top 1000 row preview" for `pyspark_connection`. Mainly because the current way does not allow for a three layer structure.
-   [x] `sparklyr` - Prevent showing the Spark and Log buttons if the connection has no target to offer
-   [ ] Implement Spark and Log buttons for Spark Connect and DB Connect. **Blocked** - Until SparkSession is implemented in Spark 3.5
-   [ ] Find a way to get the Connection pane to be async to the IDE

### Data 

- [x] `NA`'s are not supported in numeric fields, everything is translated as `NaN`

### DBI

-   [x] Integration with DBI methods. This was done my modifying a couple of `sparklyr` routines. More testing is needed to confirm all works

- Specific `DBI` functions 
    - [ ] `dbColumnInfo()` 
    - [ ] `dbWriteTable()`

### `dplyr`

-   Implement **core** methods:
    -   [x] `tbl()`
    -   [x] `collect()`
    -   [x] `compute()` 
    -   [x] `copy_to()` - Implemented for `sparklyr`'s `sdf_copy_to()` since it was already an exported method. This made it a drop in integration.
        - [ ] Re-partition does not seem to be working
        - [ ] Caching does not seem to be working via regular the PySpark Dataframe op, it does work when I use SQL to cache (via `CACHE TABLE`) but can't re-partition that way
      
-  Implement specific functions:
    - [x] `where()` / `..._if()` - Do not plan to support predicates. Determining the field types is a very expensive operation, and it should be discouraged. `dbplyr` does not support it.  Will reconsider based on community feedback
    - [x] `sample_frac()` - Supported: `weights` No | `replace` Yes
    - [x] `sample_n()` - Supported: `weights` No | `replace` No
    - [x] `slice_max()` - Worked out-of-the-box
    - [x] `cumprod()` - Do not plan to support. `dbplyr` does not support it. Will reconsider based on community feedback.
    - [x] `distinct()` 
    - [x] Hive Operators work, such as `LIKE` via `%like%` - Worked out-of-the-box
    - [ ] High Order Functions (Arrays)
    - [x] Table joins - Added `same_src()` method for PySpark connection to get it to work
    - [x] `lead()` / `lag()` 
    - [ ] `rowSums()` - Mosts tests currently pass, but not all
    - [x] `cor()`, `cov()`, `sd()` - Worked out-of-the-box
    - [x] `weighted.mean()` - Worked out-of-the-box
  
### `tidyr`

- [ ] `fill()`
- [ ] `nest()`
- [ ] `pivot_longer()` - **In progress** - Passing most tests, 23 of 29
- [ ] `pivot_wider()` 
- [ ] `separate()`
- [ ] `unite()`
- [ ] `unnest()`

### Lower level integration

-   [x] Implement the `invoke()` method for `pysparklyr_connection`
-   [ ] Implement `invoke_new()` method for `pysparklyr_connection`. Initial implementation is available, but more testing is needed. **Blocked: MLlib not supported in Spark Connect 3.4**

### Auth

-   [ ] Implement Databricks Oauth
-   [ ] Implement Azure auth
-   [x] Implement PATH based auth

### ML

**Blocked: MLlib not supported in Spark Connect 3.4**

-   [ ] First successful run of an `ft_` functions
-   [ ] Run all `ft_` functions, and have all/most pass tests
    -   [ ] Determine what to do with functions that will not run
-   [ ] First successful run of an `ml_` functions
-   [ ] Run all `ft_` functions, and have all/most pass tests
    -   [ ] Determine what to do with functions that will not run

### SDF

-   [ ] First successful run of an `sdf_` functions
-   [ ] Run all `sdf_` functions, and have all/most pass tests
    -   [ ] Determine what to do with functions that will not run
-  Individual functions:
    - [ ] `sdf_broadcast()` **Blocked** Needs SparkContext to work

### Data

-   [x] First successful run of an `spark_read_` / `spark_write_` function
-   [x] Run all `spark_read_` / `spark_write_` functions, and have all/most pass tests - None of them work 
    -   [x] Determine what to do with functions that will not run
- Overall progress
  - [x] Worked up general plan to port over read/write functions
  - [ ] `schema` support for reading non-CSV file
  - [ ] Re-partition is being ignored by Spark connection 
  - Individual **read**  functions 
    - [x] `spark_read_csv()` 
    - [x] `spark_read_parquet()`
    - [x] `spark_read_text()`
    - [x] `spark_read_orc()`    
    - [x] `spark_read_json()`
    - [ ] `spark_read_avro()`
    - [ ] `spark_read_binary()`
    - [ ] `spark_read_source()`
    - [ ] `spark_read_delta()`
    - [ ] `spark_read_table()`
    - [ ] `spark_read_jdbc()`
    - [ ] `spark_read_libsvm()`
  - Individual **write**  functions 
    - [x] `spark_write_csv()` 
    - [x] `spark_write_parquet()`
    - [x] `spark_write_text()`
    - [x] `spark_write_json()`
    - [x] `spark_write_orc()`
    - [ ] `spark_write_avro()`
    - [ ] `spark_write_rds()`   
    - [ ] `spark_write_delta()`
    - [ ] `spark_write_source()`
    - [ ] `spark_write_table()`
    
    
### Stream

-   [ ] Test streaming

### Arrow

-   [ ] Test `arrow` integration

### Testing

-   [ ] Unit testing
-   [ ] Integration testing
    -   [x] Add exported method to skip tests based on connection
    -   [x] Add skip commands to specific tests (Ongoing)
-   [x] Environments
    -   [x] Initial run against Spark Connect
    -   [x] Initial run against Databricks Connect
-   [ ] CI
    -   [ ] Add Spark Connect to current GH Spark Tests action
    -   [ ] GH action that creates a Databricks cluster and runs tests
    -   [ ] GH action that creates a Azure cluster and runs tests
