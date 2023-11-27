skip_on_ci()

test_that("Databricks installations work", {

  env_paths <- map(1:3, ~ fs::path(tempdir(), random_table_name("env")))

  version_1 <- "14.0"
  version_2 <- "13.0"
  cluster_id <- Sys.getenv("DATABRICKS_CLUSTER_ID")

  withr::with_envvar(
    new = c("WORKON_HOME" = env_paths[[1]]),
    {
    install_databricks(cluster_id = cluster_id, install_ml = FALSE, as_job = FALSE)
    expect_equal(
      length(find_environments("r-sparklyr-databricks")),
      1
    )})

  withr::with_envvar(
    new = c("WORKON_HOME" = env_paths[[2]]),
    {
    install_databricks(version_1, install_ml = FALSE,  as_job = FALSE)
    expect_equal(
      length(find_environments("r-sparklyr-databricks")),
      1
    )})

  withr::with_envvar(
    new = c("WORKON_HOME" = env_paths[[3]]),
    {
    install_databricks(version_1, install_ml = FALSE,  as_job = FALSE)
    install_databricks(version_2, install_ml = FALSE,  as_job = FALSE)
    install_databricks(cluster_id = cluster_id, install_ml = FALSE,  as_job = FALSE)
    expect_equal(
      length(find_environments("r-sparklyr-databricks")),
      3
    )})

  map(env_paths, fs::dir_delete)
})
