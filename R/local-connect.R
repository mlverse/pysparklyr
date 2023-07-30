local_connect_start <- function(version = "3.4") {

  get_version <- sparklyr::spark_install_find(version = version)

  cmd <- path(get_version$sparkVersionDir, "sbin", "start-connect-server.sh")

  scala <- "2.12"

  args <- c(
    "--packages",
    glue("org.apache.spark:spark-connect_{scala}:{get_version$sparkVersion}")
  )

  prs <- process$new(
    command = cmd,
    args = args,
    stdout = "|",
    stderr = "|",
    stdin = "|"
    )

   cli_text("-- Starting Spark Connect locally ...")
   output <- prs$read_all_output()
   cli_text(output)
   invisible()
}
