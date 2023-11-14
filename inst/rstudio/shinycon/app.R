library(sparklyr)

rsApiUpdateDialog <- function(code) {
  if (exists(".rs.api.updateDialog")) {
    updateDialog <- get(".rs.api.updateDialog")
    updateDialog(code = code)
  }
}

rsApiShowDialog <- function(title, message, url = "") {
  if (exists(".rs.api.showDialog")) {
    showDialog <- get(".rs.api.showDialog")
    showDialog(title, message, url)
  }
}

rsApiShowPrompt <- function(title, message, default) {
  if (exists(".rs.api.showPrompt")) {
    showPrompt <- get(".rs.api.showPrompt")
    showPrompt(title, message, default)
  }
}

rsApiShowQuestion <- function(title, message, ok, cancel) {
  if (exists(".rs.api.showQuestion")) {
    showPrompt <- get(".rs.api.showQuestion")
    showPrompt(title, message, ok, cancel)
  }
}

rsApiReadPreference <- function(name, default) {
  if (exists(".rs.api.readPreference")) {
    readPreference <- get(".rs.api.readPreference")
    value <- readPreference(name)
    if (is.null(value)) default else value
  }
}

rsApiWritePreference <- function(name, value) {
  if (!is.character(value)) {
    stop("Only character preferences are supported")
  }

  if (exists(".rs.api.writePreference")) {
    writePreference <- get(".rs.api.writePreference")
    writePreference(name, value)
  }
}

env_var_host <- function() {
  ret <- Sys.getenv("DATABRICKS_HOST", unset = NA)
  if(is.na(ret)) ret <- ""
  ret
}

rsApiVersionInfo <- function() {
  if (exists(".rs.api.versionInfo")) {
    versionInfo <- get(".rs.api.versionInfo")
    versionInfo()
  }
}

is_java_available <- function() {
  #nzchar(spark_get_java())
  TRUE
}

spark_home <- function() {
  home <- Sys.getenv("SPARK_HOME", unset = NA)
  if (is.na(home)) {
    home <- NULL
  }
  home
}

spark_ui_avaliable_versions <- function() {
  tryCatch(
    {
      spark_available_versions(show_hadoop = TRUE, show_minor = TRUE)
    },
    error = function(e) {
      warning(e)
      spark_installed_versions()[, c("spark", "hadoop")]
    }
  )
}

spark_ui_spark_choices <- function() {
  availableVersions <- spark_ui_avaliable_versions()
  selected <- spark_default_version()[["spark"]]
  choiceValues <- unique(availableVersions[["spark"]])

  choiceNames <- choiceValues
  choiceNames <- lapply(
    choiceNames,
    function(e) if (e == selected) paste(e, "(Default)") else e
  )

  names(choiceValues) <- choiceNames

  choiceValues
}

spark_ui_hadoop_choices <- function(sparkVersion) {
  availableVersions <- spark_ui_avaliable_versions()

  selected <- spark_install_find(version = sparkVersion, installed_only = FALSE)$hadoopVersion

  choiceValues <- unique(availableVersions[availableVersions$spark == sparkVersion, ][["hadoop"]])
  choiceNames <- choiceValues
  choiceNames <- lapply(
    choiceNames,
    function(e) if (length(selected) > 0 && e == selected) paste(e, "(Default)") else e
  )

  names(choiceValues) <- choiceNames

  choiceValues
}

#' @import rstudioapi
connection_spark_ui <- function() {
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
            label = "", value = "",
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
        tags$td("Master:"),
        div(
        tags$td(
            textInput(
              inputId = "host_url",
              label = "",
              value = env_var_host(),
              width = "400px"
            )
          ))
      ),
      tags$tr(
        tags$td(style = paste("height: 0px")),
        tags$td(textOutput("matches_host"))
      ),
      tags$tr(
        tags$td(style = paste("height: 5px"))
      ),
      tags$tr(
        tags$td("Auth:"),
        tags$td(textOutput("auth"))
      )
    )
  )
}

token_source <- function() {
  t_source <- ""
  if (exists(".rs.api.getDatabricksToken")) {
    getDatabricksToken <- get(".rs.api.getDatabricksToken")
    if(!is.null(getDatabricksToken(workspace))) {
      t_source <- "oauth"
    }
  }
  if(t_source == "" && !is.na(Sys.getenv("DATABRICKS_TOKEN", unset = NA))) {
    t_source <- "token"
  }
  t_source
}

connection_spark_server <- function(input, output, session) {

  dbr_version <- reactiveVal("")
  dbr_env_name <- reactiveVal("")

  output$auth <- reactive({
    t_source <- token_source()
    if(t_source == "token") {
      ret <- "✓ Found - Using value from 'DATABRICKS_TOKEN'"
    }
    if(t_source == "oauth") {
      ret <- "✓ Found - Using value from Posit Workbench OAuth"
    }
    if(t_source == "") {
      ret <- "✘ Not Found - Add it to your 'DATABRICKS_TOKEN' env variable"
    }
    ret
  })

  output$matches_host <- reactive({
    ret <- ""
    if(input$host_url != env_var_host()) {
      ret <- "✓ Using supplied custom Host URL in code"
    }
    if(env_var_host() == "") ret <- ""
    ret
  })

  output$get_version <- reactive({
    ret <- ""
    if(input$cluster_id != "") {
      version <- try(pysparklyr:::cluster_dbr_version(
        cluster_id = input$cluster_id,
        host = input$host_url
        ))
      if(!inherits(version, "try-error")) {
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
    if(version != "") {
      if(!inherits(version, "try-error")) {
        not_verified <- pysparklyr:::use_envname(
          version = version,
          method = "databricks_connect"
        )
        verified <- pysparklyr:::use_envname(
          version = version,
          method = "databricks_connect",
          match_first = TRUE
        )
        if(not_verified == verified) {
          env <- paste0("✓ Found - Using '", verified, "'")
        } else {
          dbr_env_name(not_verified)
          env <- "✘ Not found - Adding installation step to code"
        }
      }
    } else {
      dbr_env_name("")
    }
    env
  })

  userInstallPreference <- NULL
  checkUserInstallPreference <- function(master, sparkSelection, hadoopSelection, prompt) {
    if (identical(master, "local") &&
      identical(rsApiVersionInfo()$mode, "desktop") &&
      identical(spark_home(), NULL)) {
      installed <- spark_installed_versions()
      isInstalled <- nrow(installed[installed$spark == sparkSelection & installed$hadoop == hadoopSelection, ])

      if (!isInstalled) {
        if (prompt && identical(userInstallPreference, NULL)) {
          userInstallPreference <<- rsApiShowQuestion(
            "Install Spark Components",
            paste(
              "Spark ",
              sparkSelection,
              " for Hadoop ",
              hadoopSelection,
              " is not currently installed.",
              "\n\n",
              "Do you want to install this version of Spark?",
              sep = ""
            ),
            ok = "Install",
            cancel = "Cancel"
          )

          userInstallPreference
        } else if (identical(userInstallPreference, NULL)) {
          FALSE
        } else {
          userInstallPreference
        }
      } else {
        FALSE
      }
    } else {
      FALSE
    }
  }

  # generateCode <- function(master, dbInterface, sparkVersion, hadoopVersion, installSpark) {
  #   paste(
  #     "library(sparklyr)\n",
  #     if (dbInterface == "dplyr") "library(dplyr)\n" else "",
  #     if (installSpark) {
  #       paste(
  #         "spark_install(version = \"",
  #         sparkVersion,
  #         "\", hadoop_version = \"",
  #         hadoopVersion,
  #         "\")\n",
  #         sep = ""
  #       )
  #     } else {
  #       ""
  #     },
  #     "sc ",
  #     "<- ",
  #     "spark_connect(master = \"",
  #     master,
  #     "\"",
  #     if (!hasDefaultSparkVersion()) {
  #       paste(
  #         ", version = \"",
  #         sparkVersion,
  #         "\"",
  #         sep = ""
  #       )
  #     } else {
  #       ""
  #     },
  #     if (!hasDefaultHadoopVersion()) {
  #       paste(
  #         ", hadoop_version = \"",
  #         hadoopVersion,
  #         "\"",
  #         sep = ""
  #       )
  #     } else {
  #       ""
  #     },
  #     ")",
  #     sep = ""
  #   )
  # }

  stateValuesReactive <- reactiveValues(codeInvalidated = 1)

  # codeReactive <- reactive({
  #   master <- input$master
  #   dbInterface <- input$dbinterface
  #   sparkVersion <- input$sparkversion
  #   hadoopVersion <- input$hadoopversion
  #   codeInvalidated <- stateValuesReactive$codeInvalidated
  #
  #   installSpark <- checkUserInstallPreference(master, sparkVersion, hadoopVersion, FALSE)
  #
  #   generateCode(master, dbInterface, sparkVersion, hadoopVersion, installSpark)
  # })

  installLater <- reactive({
    master <- input$master
    sparkVersion <- input$sparkversion
    hadoopVersion <- input$hadoopversion
  }) %>% debounce(200)

  observe({
    installLater()

    isolate({
      master <- input$master
      sparkVersion <- input$sparkversion
      hadoopVersion <- input$hadoopversion

      checkUserInstallPreference(master, sparkVersion, hadoopVersion, TRUE)
    })
  })

  code_create <- function(cluster_id, host_url, envname){
    host <- NULL
    env_host <- env_var_host()
    if(env_host != "" && env_host != host_url) {
      host <- paste0("    master = \"", host_url, "\",")
    }

    if(envname != "") {
      inst <- c(paste0("pysparklyr::install_databricks(\"", dbr_version(),"\")"), "")
    } else {
      inst <- NULL
    }

    code_lines <- c(
      inst,
      "library(sparklyr)",
      "sc <- spark_connect(",
      paste0("    cluster_id = \"", cluster_id, "\","),
      host,
      "    method = \"databricks_connect\"",
      ")"
    )
    code_lines <- code_lines[!is.null(code_lines)]
    ret <- ""
    if(cluster_id != "") {
      ret <- paste0(code_lines, collapse = "\n")
    }
    ret
  }

  code_reactive <- reactive({
    cluster_id <- input$cluster_id
    host_url <- input$host_url
    print(dbr_env_name())
    code_create(cluster_id, host_url, dbr_env_name())
  })

  observe({
    rsApiUpdateDialog(code_reactive())
  })

  observe({
    if (identical(input$master, "cluster")) {
      if (identical(rsApiVersionInfo()$mode, "desktop")) {
        rsApiShowDialog(
          "Connect to Spark",
          paste(
            "Connecting with a remote Spark cluster requires ",
            "an RStudio Server instance that is either within the cluster ",
            "or has a high bandwidth connection to the cluster.</p>",
            "<p>Please see the <strong>Using Spark with RStudio</strong> help ",
            "link below for additional details.</p>",
            sep = ""
          )
        )

        updateSelectInput(
          session,
          "master",
          selected = "local"
        )
      } else if (identical(spark_home(), NULL)) {
        rsApiShowDialog(
          "Connect to Spark",
          paste(
            "Connecting with a Spark cluster requires that you are on a system ",
            "able to communicate with the cluster in both directions, and ",
            "requires that the SPARK_HOME environment variable refers to a  ",
            "locally installed version of Spark that is configured to ",
            "communicate with the cluster.",
            "<p>Your system doesn't currently have the SPARK_HOME environment ",
            "variable defined. Please contact your system administrator to ",
            "ensure that the server is properly configured to connect with ",
            "the cluster.<p>",
            sep = ""
          )
        )

        updateSelectInput(
          session,
          "master",
          selected = "local"
        )
      } else {
        master <- rsApiShowPrompt(
          "Connect to Cluster",
          "Spark master:",
          "spark://local:7077"
        )

        updateSelectInput(
          session,
          "master",
          choices = c(
            list(master = "master"),
            master,
            spark_ui_default_connections(),
            list("Cluster..." = "cluster")
          ),
          selected = master
        )
      }
    }
  })

  currentSparkSelection <- NULL
  session$onFlushed(function() {
    if (!is_java_available()) {
      url <- ""

      message <- paste(
        "In order to connect to Spark ",
        "your system needs to have Java installed (",
        "no version of Java was detected or installation ",
        "is invalid).",
        sep = ""
      )

      if (identical(rsApiVersionInfo()$mode, "desktop")) {
        message <- paste(
          message,
          "<p>Please contact your server administrator to request the ",
          "installation of Java on this system.</p>",
          sep = ""
        )

        url <- "this-is-the-java-url"  #  java_install_url()
      } else {
        message <- paste(
          message,
          "<p>Please contact your server administrator to request the ",
          "installation of Java on this system.</p>",
          sep = ""
        )
      }

      rsApiShowDialog(
        "Java Required for Spark Connections",
        message,
        url
      )
    }

    currentSparkSelection <<- spark_default_version()$spark
  })

  observe({
    # Scope this reactive to only changes to spark version
    sparkVersion <- input$sparkversion
    master <- input$master

    # Don't change anything while initializing
    if (!identical(currentSparkSelection, NULL)) {
      currentSparkSelection <<- sparkVersion

      hadoopDefault <- spark_install_find(version = currentSparkSelection, installed_only = FALSE)$hadoopVersion

      updateSelectInput(
        session,
        "hadoopversion",
        choices = spark_ui_hadoop_choices(currentSparkSelection),
        selected = hadoopDefault
      )

      stateValuesReactive$codeInvalidated <<- isolate({
        stateValuesReactive$codeInvalidated + 1
      })
    }
  })

  #outputOptions(output, "env_var_host", suspendWhenHidden = FALSE)
}

shinyApp(connection_spark_ui, connection_spark_server)
