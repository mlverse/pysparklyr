skip_if_not_databricks()

test_that("deploy works", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    {
      dbr_version <- test_databricks_cluster_version()
      cluster_id <- test_databricks_cluster_id()
      env_path <- test_databricks_deploy_env_path()

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

test_that("deploy works", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    {
      deploy_folder <- path(tempdir(), random_table_name("dep"))
      dir_create(deploy_folder)
      deploy_file <- path(deploy_folder, "test.qmd")
      writeLines("x", con = deploy_file)
      dbr_version <- test_databricks_cluster_version()
      cluster_id <- test_databricks_cluster_id()
      env_path <- test_databricks_deploy_env_path()
      local_mocked_bindings(
        check_interactive = function(...) TRUE,
        check_rstudio = function(...) TRUE,
        menu = function(...) return(1),
        deployApp = function(...) list(...),
        getSourceEditorContext = function(...) {
          x <- list()
          x$path <- deploy_file
          x
        }
        )
      expect_equal(
        deploy_databricks(
          version = dbr_version,
          server = "my_server",
          account = "my_account",
          confirm = TRUE
        ),
        list(
          appDir = deploy_folder,
          python = env_path,
          envVars = c("DATABRICKS_HOST", "DATABRICKS_TOKEN"),
          server = "my_server",
          account = "my_account",
          lint = FALSE
        )
      )
    }
  )
})

test_that("deploy works", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    {
      env_path <- test_databricks_deploy_env_path()
      local_mocked_bindings(
        py_exe = function(...) return(NULL)
      )
      expect_equal(
        deploy_find_environment(python = env_path),
        env_path
      )
      expect_error(
        deploy_find_environment()
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
