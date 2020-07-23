#' Create bulk import
#'
#' @param conn \code{Td} client
#' @param name Bulk import session name
#' @param dbname Data base name
#' @param table Table name
#' @return Return \code{TRUE} if succeeded
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxx")
#' sess_name <- uuid::UUIDgenerate()
#' create_bulk_import(conn, sess_name, "mydb", "mytable")
#' }
#'
#' @export
create_bulk_import <- function(conn, name, dbname, table) {
  res <- .post(conn, paste0("/v3/bulk_import/create/", name, "/", dbname, "/", table), character(0))
  return(TRUE)
}

#' Delete bulk import
#'
#' @param conn \code{Td} client
#' @param name Bulk import session name
#' @return Return \code{TRUE} if succeeded
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxx")
#' delete_bulk_import(conn, sess_name)
#' }
#'
#' @export
delete_bulk_import <- function(conn, name) {
  .post(conn, paste0("/v3/bulk_import/delete/", name), character(0))
  return(TRUE)
}

#' Show bulk import
#'
#' @param conn \code{Td} client
#' @param name Bulk import session name
#' @return Return bulk import status
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxx")
#' show_bulk_import(conn, sess_name)
#' }
#'
#' @export
show_bulk_import <- function(conn, name) {
  res <- .get(conn, paste0("/v3/bulk_import/show/", name))
  return(res)
}


#' List bulk imports
#'
#' @param conn \code{Td} client
#' @return Return bulk import list
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxx")
#' list_bulk_import(conn)
#' }
#'
#' @export
list_bulk_imports <- function(conn) {
  res <- .get(conn, paste0("/v3/bulk_import/list"))
  return(res)
}

#' List bulk import parts
#'
#' @param conn \code{Td} client
#' @param name Bulk import session name
#' @return Return bulk import parts list
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxx")
#' list_bulk_import_parts(conn, sess_name)
#' }
#'
#' @export
list_bulk_import_parts <- function(conn, name) {
  res <- .get(conn, paste0("/v3/bulk_import/list_parts/", name))
  return(res)
}

#' Upload bulk import part
#'
#' @param conn \code{Td} client
#' @param name Bulk import session name
#' @param part_name Bulk import part name
#' @param file_obj File connection. Should be msgpack stream with gzip compressed. Should have "time" column
#' @return Return bulk import status
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxx")
#, tf <- tempfile(fileext = ".msgpack.gz")
#, on.exit(unlink(tf))
#, msgconn <- gzfile(tf, open="w+b")
#, if (!("time" %in% colnames(df))) {
#,   df$time = as.integer(Sys.time())
#, }
#, buf <- df %>% purrr::map_if(is.factor, as.character) %>%
#, purrr::pmap(list) %>% do.call(RcppMsgPack::msgpack_pack, .)
#, writeBin(buf, msgconn)
#, close(msgconn)
#, bulk_import_upload_part(conn, sess_name, "part", tf)
#' }
#'
#' @export
bulk_import_upload_part <- function(conn, name, part_name, file_obj) {
  .put(
    conn,
    paste0("/v3/bulk_import/upload_part/", name, "/", part_name),
    httr::upload_file(file_obj, type="application/octetstream")
  )
  return(TRUE)
}

#' Delete bulk import part
#'
#' @param conn \code{Td} client
#' @param name Bulk import session name
#' @param part_name Bulk import part name
#' @return Return \code{TRUE} if succeeded
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxx")
#' bulk_import_delete_part(conn, sess_name, "part")
#' }
#'
#' @export
bulk_import_delete_part <- function(conn, name, part_name) {
  .post(conn, paste0("/v3/bulk_import/delete_part/", name , "/", part_name), character(0))
  return(TRUE)
}

#' Freeze bulk import part
#'
#' @param conn \code{Td} client
#' @param name Bulk import session name
#' @return Return \code{TRUE} if succeeded
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxx")
#' freeze_bulk_import(conn, sess_name)
#' }
#'
#' @export
freeze_bulk_import <- function(conn, name) {
  .post(conn, paste0("/v3/bulk_import/freeze/", name), character(0))
  return(TRUE)
}

#' Unfreeze bulk import part
#'
#' @param conn \code{Td} client
#' @param name Bulk import session name
#' @return Return \code{TRUE} if succeeded
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxx")
#' unfreeze_bulk_import(conn, sess_name)
#' }
#'
#' @export
unfreeze_bulk_import <- function(conn, name) {
  .post(conn, paste0("/v3/bulk_import/freeze/", name), character(0))
  return(TRUE)
}


#' Perform bulk import part
#'
#' @param conn \code{Td} client
#' @param name Bulk import session name
#' @return Return \code{TRUE} if succeeded
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxx")
#' perform_bulk_import(conn, sess_name)
#' }
#'
#' @export
perform_bulk_import <- function(conn, name) {
  res <- .post(conn, paste0("/v3/bulk_import/perform/", name), character(0))
  return(res$job_id)
}

#' Commit bulk import part
#'
#' @param conn \code{Td} client
#' @param name Bulk import session name
#' @return Return \code{TRUE} if succeeded
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxx")
#' commit_bulk_import(conn, sess_name)
#' }
#'
#' @export
commit_bulk_import <- function(conn, name) {
  res <- .post(conn, paste0("/v3/bulk_import/commit/", name), character(0))
  return(TRUE)
}

#' Show bulk import error records
#'
#' @param conn \code{Td} client
#' @param name Bulk import session name
#' @return Return error records in gzipped file with msgpack stream format.
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxx")
#' bulk_import_error_records(conn, sess_name)
#' }
#'
#' @export
bulk_import_error_records <- function(conn, name) {
  res <- .get(conn, paste0("/v3/bulk_import/error_records/", name))
  # TODO: uncompress gzip file and unpack msgpack
  return(res)
}

#' Wait bulk import until finished
#'
#' @param conn \code{Td} client
#' @param sess_name Bulk import session name
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxx")
#' wait_bulk_import(conn, sess_name)
#' }
#'
#' @export
wait_bulk_import <- function(conn, sess_name) {
  status <- show_bulk_import(conn, sess_name)
  while(status$status != "committed"){
    Sys.sleep(10)
    status <- show_bulk_import(conn, sess_name)
  }
}
