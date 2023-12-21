skip_if_not_databricks()

test_that("deploy works", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    {
      dbr_version <- databricks_dbr_version(
        cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID"),
        host = databricks_host(),
        token = databricks_token()
      )

      env_name <- use_envname(
        version = dbr_version,
        method = "databricks_method"
      )

      if (names(env_name) != "exact") {
        install_environment(
          libs = "databricks.connect",
          version = dbr_version,
          envname = env_name,
          python_version = ">=3.9",
          new_env = TRUE,
          install_packages = c("numpy")
        )
      }

      local_mocked_bindings(
        deployApp = function(...) list(...),
        accounts = function(...) {
          data.frame(name = "my_account", server = "my_server")
        }
      )

      env_path <- path(reticulate::virtualenv_python(env_name))

      expect_equal(
        deploy_databricks(version = dbr_version),
        list(
          appDir = path(getwd()),
          python = env_path,
          envVars = c("DATABRICKS_HOST", "DATABRICKS_TOKEN"),
          server = "my_server",
          account = "my_account",
          lint = FALSE
        )
      )

      expect_equal(
        deploy_databricks(version = dbr_version, appTitle = "My Cool Title"),
        list(
          appDir = path(getwd()),
          python = env_path,
          envVars = c("DATABRICKS_HOST", "DATABRICKS_TOKEN"),
          server = "my_server",
          account = "my_account",
          lint = FALSE,
          appTitle = "My Cool Title"
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
              python = env_path,
              envVars = c("CONNECT_DATABRICKS_HOST", "CONNECT_DATABRICKS_TOKEN"),
              server = "my_server",
              account = "my_account",
              lint = FALSE
            )
          )
        }
      )
    }
  )
})
