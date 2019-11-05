#' @include table.R database.R
NULL

#' Upload data.frame to TD
#'
#' @param conn \code{Td} connection
#' @param dbname Target destination database name.
#' @param table Target table name.
#' @param df Input data.frame.
#' @param mode Write mode. "bulk_import" or "embulk". Default: "bulk_import"
#' @param embulk_dir Path to embulk. [optional]
#' @param overwrite Flag for overwriting the table if exists. It doesn't overwrite database. This flag sets "replace" mode for embulk-output-td.
#' @param append Flag for append data into the table if exists. It doesn't overwrite database. This flag sets "append" mode for embulk-output-td.
#'
#' @examples
#' \dontrun{
#' td_upload_embulk("mydb", "iris", iris)
#'
#' # With overwrite option
#' td_upload_embulk("mydb", "iris", iris, overwrite = TRUE)
#'
#' # With append option
#' td_upload_embulk("mydb", "iris", iris, append = TRUE)
#'
#' # With overwrite option
#' td_upload_embulk("mydb", "iris", iris, "/path/to/embulk", overwrite = TRUE)
#' }
#'
#' @importFrom readr write_tsv
#' @export
td_upload <- function(conn, dbname, table, df, mode = "bulk_import", embulk_dir, overwrite = FALSE, append = FALSE) {

  exists_db <- exist_database(conn, dbname)
  exists_table <- exist_table(conn, dbname, table)
  if (!overwrite && !append && exists_table) {
    stop(paste0('"', dbname, ".", table, '" already exists.'))
  }
  if (!exists_db) {
    create_database(conn, dbname)
  }

  if (mode == "bulk_import") {
    td_bulk_upload(conn, dbname, table, df, overwrite = overwrite, append = append)
  } else if (mode == "embulk") {
    td_embulk_upload(conn, dbname, table, df, embulk_dir, overwrite = overwrite, append = append)
  }

}

td_embulk_upload <- function(conn, dbname, table, df, embulk_dir, overwrite = FALSE, append = FALSE) {
  embulk_exec <- ifelse(missing(embulk_dir), "embulk", file.path(embulk_dir, "embulk"))
  if (.Platform$OS.type == "windows") {
    embulk_exec <- paste0(embulk_exec, ".bat")
  }

  if (Sys.which(embulk_exec) == "") {
    stop("Unable to find embulk. Ensure PATH is set for embulk or use embulk_dir option.")
  }

  # Use "replace" mode by default.
  write_mode <- "replace"
  if (append) {
    write_mode <- "append"
  }

  template_path <- system.file("extdata", "tsv_upload.yml.liquid", package = "RTD")
  temp_dir <- tempdir()
  temp_tsv <- tempfile(fileext = ".tsv", pattern = "embulk_", tmpdir = temp_dir)

  proxy_settings <- conn$http_proxy
  if (identical(proxy_settings, character(0))) {
    http_proxy <- ""
  } else {
    http_proxy <- paste0("http_proxy: {host: ", proxy_settings["host"], ", port: ", proxy_settings["port"], ", use_ssl: ", proxy_settings["use_ssl"])
    if (!is.na(proxy_settings["user"])) {
      http_proxy <- paste0(http_proxy, ',user: "', proxy_settings["user"], '"')
    }
    if (!is.na(proxy_settings["password"])) {
      http_proxy <- paste0(http_proxy, ',password: "', proxy_settings["password"], '"')
    }
    http_proxy <- paste0(http_proxy, "}")
  }

  # Replace NA as an empty string
  readr::write_tsv(df, temp_tsv, na = "")
  load_yml <- file.path(temp_dir, "load.yml")

  # Set environment variable for embulk
  Sys.setenv(dbname = dbname, table = table, path_prefix = temp_tsv, http_proxy = http_proxy, apikey = conn$apikey, endpoint = conn$endpoint, mode = write_mode)

  system2(embulk_exec, paste("guess", template_path, "-o", load_yml))
  system2(embulk_exec, paste("run", load_yml))
}

td_bulk_upload <- function(conn, dbname, table, df, overwrite = FALSE, append = FALSE){
  if (overwrite) {
    delete_table(conn, dbname, table)
    create_table(conn, dbname, table)
  }
  exists_table <- exist_table(conn, dbname, table)
  if (!exists_table) {
    create_table(conn, dbname, table)
  }

  sess_name <- uuid::UUIDgenerate()
  create_bulk_import(conn, sess_name, dbname, table)
  tf <- tempfile(fileext = ".msgpack.gz")
  on.exit(unlink(tf))
  msgconn <- gzfile(tf, open="w+b")
  if (!("time" %in% colnames(df))) {
    df$time = as.integer(Sys.time())
  }
  apply(df, 1, function(x) {msgpack::writeMsg(x, msgconn)})
  close(msgconn)
  part_name <- "part"
  bulk_import_upload_part(conn, sess_name, part_name, tf)
  freeze_bulk_import(conn, sess_name)
  job_id <- perform_bulk_import(conn, sess_name)
  job_wait(conn, job_id)
  res <- commit_bulk_import(conn, sess_name)
  status <- show_bulk_import(conn, sess_name)
  wait_bulk_import(conn, sess_name)
  delete_bulk_import(conn, sess_name)
}

.guess_column_types <- function(df) {
  guessed_types <- sapply(df, function(x) {
    if (is.factor(x) || is.character(x)) {
      "string"
    } else if (is.list(x)) {
      "list"
    } else if (all(x %% 1 == 0)) {
      "int"
    } else {
      "double"
    }
  })

  return(paste(guessed_types, collapse = ","))
}
