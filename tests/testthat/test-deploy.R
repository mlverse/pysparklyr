skip_if_not_databricks()

test_that("deploy works", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    {
      cluster_id <- Sys.getenv("DATABRICKS_CLUSTER_ID")

      dbr_version <- databricks_dbr_version(
        cluster_id = cluster_id,
        host = databricks_host(),
        token = databricks_token()
      )

      env_name <- use_envname(
        version = dbr_version,
        backend = "databricks"
      )

      if (names(env_name) != "exact") {
        py_install("numpy", env_name, pip = TRUE, python = Sys.which("python"))
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
        deploy_databricks(cluster_id = cluster_id),
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

      withr::with_envvar(
        new = c("DATABRICKS_HOST" = NA, "DATABRICKS_TOKEN" = NA),
        {
          expect_error(
            deploy_databricks(
              version = dbr_version
            )
          )
        }
      )

    }
  )
})

test_that("Misc deploy tests", {
  expect_error(deploy(), "'backend'")

  local_mocked_bindings(
    accounts = function(...) data.frame()
  )

  expect_error(
    deploy(backend = "databricks"),
    "There are no server accounts setup"
  )
})
