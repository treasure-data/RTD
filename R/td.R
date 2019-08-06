#' @include table.R database.R
NULL

#' Upload data.frame to TD
#'
#' @param conn \code{Td} connection
#' @param dbname Target destination database name.
#' @param table Target table name.
#' @param df Input data.frame.
#' @param embulk_dir Path to embulk. [optional]
#' @param overwrite Flag for overwriting the table if exists. It doesn't overwrite database.
#'
#' @examples
#' \dontrun{
#' td_upload_embulk("mydb", "iris", iris)
#'
#' # With overwrite option
#' td_upload_embulk("mydb", "iris", iris, overwrite = TRUE)
#'
#' # With overwrite option
#' td_upload_embulk("mydb", "iris", iris, "/path/to/embulk", overwrite = TRUE)
#' }
#'
#' @importFrom readr write_tsv
#' @export
td_upload <- function(conn, dbname, table, df, embulk_dir, overwrite = FALSE) {
  embulk_exec <- ifelse(missing(embulk_dir), "embulk", file.path(embulk_dir, "embulk"))
  if(.Platform$OS.type == "windows") {
    embulk_exec <- paste0(embulk_exec, ".bat")
  }

  if(Sys.which(embulk_exec) == ''){
    stop("embulk isn't found. Ensure PATH is set for embulk or use embulk_dir option.")
  }

  exists_db <- exist_database(conn, dbname)
  exists_table <- exist_table(conn, dbname, table)
  if(!overwrite && exists_table) {
    stop(paste0('"', dbname, ".", table, '" already exists.'))
  }
  if(!exists_db) {
    create_database(conn, dbname)
  }
  if(overwrite && exists_table) {
    delete_table(conn, dbname, table)
  }
  create_table(conn, dbname, table)

  template_path <- system.file("extdata", "tsv_upload.yml.liquid", package="RTD")
  temp_dir <- tempdir()
  temp_tsv <- tempfile(fileext = ".tsv", pattern = "embulk_", tmpdir = temp_dir)

  proxy_settings <- conn$http_proxy
  if(identical(proxy_settings, character(0))) {
    http_proxy <- ""
  } else {
    http_proxy <- paste0("http_proxy: {host: ", proxy_settings['host'], ", port: ", proxy_settings['port'], ", use_ssl: ", proxy_settings['use_ssl'])
    if(!is.na(proxy_settings['user'])) {
      http_proxy <- paste0(http_proxy, ',user: "', proxy_settings['user'], '"')
    }
    if(!is.na(proxy_settings['password'])) {
      http_proxy <- paste0(http_proxy, ',password: "', proxy_settings['password'], '"')
    }
    http_proxy <- paste0(http_proxy, "}")
  }

  # Replace NA as an empty string
  readr::write_tsv(df, temp_tsv, na= "")
  load_yml <- file.path(temp_dir, "load.yml")

  # Set environment variable for embulk
  Sys.setenv(dbname=dbname, table=table, path_prefix=temp_tsv, http_proxy=http_proxy, TD_API_KEY=conn$apikey, TD_API_SERVER=conn$endpoint)

  system2(embulk_exec, paste("guess", template_path, "-o", load_yml))
  system2(embulk_exec, paste("run", load_yml))
}

.guess_column_types <- function(df) {
  guessed_types <- sapply(df, function(x){
    if(is.factor(x) || is.character(x)) {
      "string"
    } else if(all(x%%1 == 0)) {
      "int"
    } else {
      "double"
    }
  })

  return(paste(guessed_types, collapse = ','))
}
