library(sparklyr)

rsApiUpdateDialog <- function(code) {
  if (exists(".rs.api.updateDialog")) {
    updateDialog <- get(".rs.api.updateDialog")
    updateDialog(code = code)
  }
}

#' @import rstudioapi
connection_spark_ui <- function() {
  env_var_name <- "DATABRICKS_SELECTED_CLUSTER_ID"
  if(Sys.getenv(env_var_name) != "") {
    cluster_label <- Sys.getenv(env_var_name)
    Sys.unsetenv(env_var_name)
  } else {
    cluster_label <- ""
  }

  elementSpacing <- if (.Platform$OS.type == "windows") 2 else 7

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
        tags$td(textOutput("get_env"))
      ),
      tags$tr(
        tags$td(style = paste("height: 5px"))
      ),
      tags$tr(
        tags$td("Host URL:"),
        div(
          tags$td(
            textInput(
              inputId = "host_url",
              label = "",
              value = pysparklyr:::databricks_host(fail = FALSE),
              width = "400px"
            )
          )
        )
      ),
      tags$tr(
        tags$td(style = paste("height: 0px")),
        tags$td(textOutput("matches_host"))
      ),
      tags$tr(
        tags$td(style = paste("height: 5px"))
      ),
      tags$tr(
        tags$td("Password:"),
        tags$td(textOutput("auth"))
      )
    )
  )
}

connection_spark_server <- function(input, output, session) {
  dbr_version <- reactiveVal("")
  token <- pysparklyr:::databricks_token()

  output$auth <- reactive({
    t_source <- names(token)
    if (t_source == "environment") {
      ret <- "✓ Found - Using 'DATABRICKS_TOKEN'"
    }
    if (t_source == "oauth") {
      ret <- "✓ Found - Managed by Posit Workbench OAuth"
    }
    if (t_source == "") {
      ret <- "✘ Not Found - Add it to your 'DATABRICKS_TOKEN' env variable"
    }
    ret
  })

  output$matches_host <- reactive({
    host <- pysparklyr:::databricks_host(fail = FALSE)
    ret <- ""
    if (input$host_url != host) {
      ret <- "✓ Using supplied custom Host URL in code"
    }
    if (host == "") ret <- ""
    ret
  })

  output$get_version <- reactive({
    ret <- ""
    if (input$cluster_id != "") {
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
        ret <- "✘ Could not verify cluster version"
      }
    }
    ret
  })

  output$get_env <- reactive({
    env <- ""
    version <- dbr_version()
    if (version != "") {
      if (!inherits(version, "try-error")) {
        verified <- pysparklyr:::use_envname(
          version = version,
          method = "databricks_connect",
          messages = FALSE,
          match_first = FALSE,
          ignore_reticulate_python = TRUE
        )
        verified_name <- names(verified)
        if (verified_name == "exact") {
          env <- paste0("✓ Found - Using '", verified, "'")
        } else {
          env <- " !  Not found - You will be prompted to install"
        }
      }
    }

    env
  })

  code_create <- function(cluster_id, host_url) {
    host <- NULL
    env_host <- pysparklyr:::databricks_host(fail = FALSE)
    if (env_host != "" && env_host != host_url) {
      host <- paste0("    master = \"", host_url, "\",")
    }

    code_lines <- c(
      "library(sparklyr)",
      "sc <- spark_connect(",
      paste0("    cluster_id = \"", cluster_id, "\","),
      host,
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
    cluster_id <- input$cluster_id
    host_url <- input$host_url
    code_create(cluster_id, host_url)
  })

  observe({
    rsApiUpdateDialog(code_reactive())
  })
}

shinyApp(connection_spark_ui, connection_spark_server)
