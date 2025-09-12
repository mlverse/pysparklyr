library(rlang)

rsApiUpdateDialog <- function(code) {
  if (exists(".rs.api.updateDialog")) {
    updateDialog <- get(".rs.api.updateDialog")
    updateDialog(code = code)
  }
}

is_windows <- function() {
  identical(.Platform$OS.type, "windows")
}

# Copied from reticulate
is_virtualenv <- function(dir) {
  # check for expected files for virtualenv / venv
  subdir <- if (is_windows()) "Scripts" else "bin"
  files <- c(
    file.path(subdir, "activate_this.py"),
    file.path(subdir, "pyvenv.cfg"),
    "pyvenv.cfg"
  )
  paths <- file.path(dir, files)
  any(file.exists(paths))
}


#' @import rstudioapi
connection_spark_ui <- function() {
  env_var_name <- "DATABRICKS_SELECTED_CLUSTER_ID"
  if (Sys.getenv(env_var_name) != "") {
    cluster_label <- Sys.getenv(env_var_name)
    Sys.unsetenv(env_var_name)
  } else {
    cluster_label <- ""
  }

  elementSpacing <- if (is_windows()) 2 else 7

  tags$div(
    tags$style(
      type = "text/css",
      paste0(
        "table {
          font-family: 'Verdana', 'Helvetica';
          font-size: 12px;
        }",
        ".shiny-input-text {
          font-family: 'Verdana', 'Helvetica';
          font-size: 12px;
          width: 100%;
        }"
      )
    ),
    tags$table(
      tags$tr(
        tags$td("Cluster ID:"),
        tags$td(
          textInput(
            inputId = "cluster_id",
            label = "",
            value = cluster_label,
            width = "200px"
          ),
          textOutput("get_version"),
          style = paste("height: 20px")
        )
      ),
      tags$tr(
        tags$td(style = paste("height: 5px"))
      ),
      tags$tr(
        tags$td("Python Env:"),
        tags$td(uiOutput("get_env"))
      ),
      tags$tr(
        tags$td(style = paste("height: 5px"))
      ),
      tags$tr(
        tags$td(textOutput("dbr_label")),
        tags$td(uiOutput("dbr_ui"))
      ),
      tags$tr(
        tags$td(textOutput("host_label")),
        tags$td(uiOutput("host_ui"))
      ),
      tags$tr(
        tags$td(style = paste("height: 0px")),
        tags$td(textOutput("matches_host"))
      ),
      tags$tr(
        tags$td(style = paste("height: 5px"))
      ),
      tags$tr(
        tags$td(textOutput("auth_label")),
        tags$td(textOutput("auth_ui"))
      )
    )
  )
}

connection_spark_server <- function(input, output, session) {
  dbr_version <- reactiveVal("")
  token <- pysparklyr:::databricks_token()
  host <- pysparklyr:::databricks_host(fail = FALSE)
  output$auth_label <- reactive({
    ret <- ""
    if (!is.null(names(token))) {
      ret <- "Password:"
    }
    ret
  })

  output$auth_ui <- reactive({
    t_source <- names(token)
    if (is.null(t_source)) {
      ret <- ""
    } else {
      if (t_source == "environment") {
        ret <- "✓ Found - Using 'DATABRICKS_TOKEN'"
      }
      if (t_source == "oauth") {
        ret <- "✓ Found - Managed by Posit Workbench OAuth"
      }
      if (t_source == "") {
        ret <- "✘ Not Found - Add it to your 'DATABRICKS_TOKEN' env variable"
      }
    }
    ret
  })

  output$host_label <- reactive({
    ret <- ""
    if (host != "") {
      ret <- "Host URL:"
    }
    ret
  })

  output$host_ui <- renderUI({
    if (host == "") {
      tags$p("")
    } else {
      textInput(
        inputId = "host_url",
        label = "",
        value = host,
        width = "400px"
      )
    }
  })

  output$dbr_label <- reactive({
    ret <- ""
    if (token == "") {
      ret <- "DBR Version:"
    }
    ret
  })

  output$dbr_ui <- renderUI({
    if (token != "") {
      ret <- tags$p("")
    } else {
      ret <- textInput(
        inputId = "dbr_ver",
        label = "",
        value = "",
        width = "50px"
      )
    }
    ret
  })

  output$matches_host <- reactive({
    ret <- ""
    if (!is.null(input$host)) {
      if (input$host != host) {
        ret <- "✓ Using supplied custom Host URL in code"
      }
      if (host == "") ret <- ""
      ret
    }
  })

  output$get_version <- reactive({
    ret <- ""
    host_url <- input$host_url %||% ""
    if (input$cluster_id != "" && host_url != "") {
      version <- try(pysparklyr:::databricks_dbr_version(
        cluster_id = input$cluster_id,
        host = input$host_url,
        token = token
      ))
      if (!inherits(version, "try-error")) {
        dbr_version(version)
        ret <- paste0("✓ Found - Cluster's DBR is ", version)
      } else {
        dbr_version("")
        if (token != "") {
          ret <- "✘ Could not verify cluster version"
        }
      }
    }
    ret
  })

  output$get_env <- renderUI({
    env <- c(
      "Create a temporary UV environment" = "default",
      "Let {reticulate} find an environment" = "reticulate"
    )
    sel_env <- "default"
    env_folders <- c(".venv", ".virtualenv")
    active_project <- try(rstudioapi::getActiveProject(), silent = TRUE)
    if (!inherits(active_project, "try-error")) {
      env_folders <- c(env_folders, file.path(active_project, env_folders))
    }
    for (folder in env_folders) {
      if (is_virtualenv(folder)) {
        sel_env <- folder
        env <- c(env, folder)
      }
    }

    version <- input$dbr_ver %||% dbr_version()
    try_version <- try(pysparklyr:::version_prep(version), silent = TRUE)
    err_version <- inherits(try_version, "try-error")
    if (version != "" && !err_version) {
      if (!inherits(version, "try-error")) {
        verified <- pysparklyr:::use_envname(
          version = version,
          backend = "databricks",
          messages = FALSE,
          match_first = FALSE,
          ignore_reticulate_python = TRUE
        )
        verified_name <- names(verified)
        if (verified_name == "exact") {
          sel_env <- verified
          env <- c(env, as.character(verified))
        }
      }
    }
    selectInput("py_env", "", choices = env, selected = sel_env)
  })

  code_create <- function(cluster_id, host_url, dbr, envname = NULL) {
    host_label <- NULL
    dbr_label <- NULL
    envname_label <- NULL

    if (is.null(host_url)) {
      host_url <- ""
    }
    if (host != "" && host != host_url) {
      host <- paste0("    master = \"", host_url, "\",")
    }
    if (!is.null(dbr)) {
      if (dbr != "") {
        dbr_label <- paste0("    version = \"", dbr, "\",")
      }
    }
    if (!is.null(envname)) {
      if (envname == "reticulate") {
        envname <- ""
      }
      if (envname != "default") {
        envname_label <- paste0("    envname = \"", envname, "\",")
      }
    }
    code_lines <- c(
      "library(sparklyr)",
      "sc <- spark_connect(",
      paste0("    cluster_id = \"", cluster_id, "\","),
      dbr_label,
      host_label,
      envname_label,
      "    method = \"databricks_connect\"",
      ")"
    )
    code_lines <- code_lines[!is.null(code_lines)]
    ret <- ""
    if (cluster_id != "") {
      ret <- paste0(code_lines, collapse = "\n")
    }
    ret
  }

  code_reactive <- reactive({
    code_create(
      cluster_id = input$cluster_id,
      host_url = input$host_url,
      dbr = input$dbr_ver %||% dbr_version(),
      envname = input$py_env
    )
  })

  observe({
    rsApiUpdateDialog(code_reactive())
  })
}

shinyApp(connection_spark_ui, connection_spark_server)
