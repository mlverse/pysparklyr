skip_if_not_databricks()

test_databricks_deploy_output <- function() {
  list(
    appDir = path(getwd()),
    python = test_databricks_stump_env(),
    envVars = c("DATABRICKS_HOST", "DATABRICKS_TOKEN"),
    server = "my_server",
    account = "my_account",
    lint = FALSE
  )
}

test_databricks_deploy_file <- function() {
  deploy_folder <- path(tempdir(), random_table_name("dep"))
  dir_create(deploy_folder)
  deploy_file <- path(deploy_folder, "test.qmd")
  writeLines("x", con = deploy_file)
  deploy_file
}

accounts_df <- function() {
  data.frame(
    name = c("my_account", "my_account2", "my_account3"),
    server = c("my_server", "my_server2", "my_server3")
  )
}

test_that("Basic use, passing DBR version works", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    {
      local_mocked_bindings(
        deployApp = function(...) list(...),
        accounts = function(...) accounts_df()
      )
      # Initializes environment
      invisible(test_databricks_stump_env())

      expect_equal(
        deploy_databricks(version = test_databricks_cluster_version()),
        test_databricks_deploy_output()
      )
    }
  )
})

test_that("Basic use, passing the cluster's ID", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    {
      local_mocked_bindings(
        deployApp = function(...) list(...),
        accounts = function(...) accounts_df()
      )
      expect_equal(
        deploy_databricks(cluster_id = test_databricks_cluster_id()),
        test_databricks_deploy_output()
      )
    }
  )
})

test_that("Use the Cluster ID from environment variable", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    {
      local_mocked_bindings(
        deployApp = function(...) list(...),
        accounts = function(...) accounts_df()
      )
      expect_equal(
        deploy_databricks(),
        test_databricks_deploy_output()
      )
    }
  )
})

test_that("Additional arguments are passed on to deployApp()", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    {
      local_mocked_bindings(
        deployApp = function(...) list(...),
        accounts = function(...) accounts_df()
      )

      out <- test_databricks_deploy_output()
      out$appTitle <- "My Cool Title"

      expect_equal(
        deploy_databricks(
          version = test_databricks_cluster_version(),
          appTitle = "My Cool Title"
        ),
        out
      )
    }
  )
})
test_that("Custom environment variables are passed when `host` and `token` are used", {
  withr::with_envvar(
    new = c(
      "WORKON_HOME" = use_test_env(),
      "CONNECT_DATABRICKS_HOST" = "",
      "CONNECT_DATABRICKS_TOKEN" = ""
    ),
    {
      local_mocked_bindings(
        deployApp = function(...) list(...),
        accounts = function(...) accounts_df()
      )

      out <- test_databricks_deploy_output()
      out$envVars <- c("CONNECT_DATABRICKS_HOST", "CONNECT_DATABRICKS_TOKEN")

      expect_equal(
        deploy_databricks(
          version = test_databricks_cluster_version(),
          host = "new_host",
          token = "new_token"
        ),
        out
      )
    }
  )
})

test_that("Fails if no host/token is found", {
  withr::with_envvar(
    new = c(
      "DATABRICKS_HOST" = NA,
      "DATABRICKS_TOKEN" = NA
    ),
    {
      expect_error(
        deploy_databricks(version = test_databricks_cluster_version()),
        "Cluster setup errors"
      )
    }
  )
})

test_that("Simulates interactive session, selects Yes (1) for both prompts", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    {
      deploy_file <- test_databricks_deploy_file()
      local_mocked_bindings(
        check_interactive = function(...) TRUE,
        check_rstudio = function(...) TRUE,
        menu = function(...) {
          return(1)
        },
        deployApp = function(...) list(...),
        accounts = function(...) accounts_df(),
        getSourceEditorContext = function(...) {
          x <- list()
          x$path <- as_fs_path(deploy_file)
          x
        }
      )
      out <- test_databricks_deploy_output()
      out$appDir <- as_fs_path(path_dir(deploy_file))

      expect_equal(
        deploy_databricks(
          version = test_databricks_cluster_version(),
          server = "my_server",
          account = "my_account",
          confirm = TRUE
        ),
        out
      )
    }
  )
})

test_that("Simulates interactive session, selects 3 for both prompts", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    {
      deploy_file <- test_databricks_deploy_file()
      local_mocked_bindings(
        check_interactive = function(...) TRUE,
        check_rstudio = function(...) TRUE,
        menu = function(...) {
          return(3)
        },
        deployApp = function(...) list(...),
        accounts = function(...) accounts_df(),
        getSourceEditorContext = function(...) {
          x <- list()
          x$path <- as_fs_path(deploy_file)
          x
        }
      )
      out <- test_databricks_deploy_output()
      out$appDir <- as_fs_path(path_dir(deploy_file))
      out$server <- "my_server3"
      out$account <- "my_account3"

      expect_equal(
        deploy_databricks(
          version = test_databricks_cluster_version(),
          confirm = TRUE
        ),
        out
      )
    }
  )
})

test_that("Rare cases for finding environments works", {
  withr::with_envvar(
    new = c("WORKON_HOME" = use_test_env()),
    {
      env_path <- test_databricks_stump_env()
      local_mocked_bindings(
        py_exe = function(...) {
          return(NULL)
        }
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
