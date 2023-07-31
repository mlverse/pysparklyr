#' Starts Spark Connect locally
#' @param version Spark version to use (3.4 or above)
#' @param scala_version Acceptable Scala version of packages to be loaded
#' @param ... Optional arguments; currently unused
#' @export
spark_connect_service_start <- function(version = "3.4",
                                        scala_version = "2.12",
                                        ...
                                        ) {
  get_version <- spark_install_find(version = version)
  cmd <- path(get_version$sparkVersionDir, "sbin", "start-connect-server.sh")
  args <- c(
    "--packages",
    glue("org.apache.spark:spark-connect_{scala_version}:{get_version$sparkVersion}")
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

#' @rdname spark_connect_service_start
#' @export
spark_connect_service_stop <- function(version = "3.4",
                                       ...
                                       ) {
  get_version <- spark_install_find(version = version)
  cmd <- path(get_version$sparkVersionDir, "sbin", "stop-connect-server.sh")
  cli_text("-- Stopping Spark Connect")
  prs <- process$new(
    command = cmd,
    stdout = "|",
    stderr = "|",
    stdin = "|"
  )

}
