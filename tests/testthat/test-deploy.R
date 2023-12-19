skip_if_not_databricks()

test_that("deploy works", {

  dbr_version <- databricks_dbr_version(
    cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID"),
    host = databricks_host(),
    token = databricks_token()
    )

  env_name <- use_envname(
    version = dbr_version,
    method = "databricks_method"
    )

  if(names(env_name) != "exact") {
    reticulate::virtualenv_create(env_name)
  }

  local_mocked_bindings(
    deployApp = function(...) list(...),
    accounts = function(...) {
      data.frame(name = "my_account", server = "my_server")
      }
    )

  expect_equal(
    deploy_databricks(version = dbr_version),
    list(
      appDir = path(getwd()),
      python = path(reticulate::virtualenv_python(env_name)),
      envVars = c("DATABRICKS_HOST", "DATABRICKS_TOKEN"),
      server = "my_server",
      account = "my_account",
      lint = FALSE
    )
  )

  withr::with_envvar(
    new = c("CONNECT_DATABRICKS_HOST" = "", "CONNECT_DATABRICKS_TOKEN" = ""),
    {
      expect_equal(
        deploy_databricks(
          version = dbr_version,
          host = "new_host",
          token = "new_token"
        ),
        list(
          appDir = path(getwd()),
          python = path(reticulate::virtualenv_python(env_name)),
          envVars = c("CONNECT_DATABRICKS_HOST", "CONNECT_DATABRICKS_TOKEN"),
          server = "my_server",
          account = "my_account",
          lint = FALSE
        )
      )
    })


})

