create_bulk_import <- function(conn, name, dbname, table) {
  res <- .post(conn, paste0("/v3/bulk_import/create/", name, "/", dbname, "/", table), character(0))
  return(TRUE)
}

delete_bulk_import <- function(conn, name) {
  .post(conn, paste0("/v3/bulk_import/delete/", name), character(0))
  return(TRUE)
}

show_bulk_import <- function(conn, name, ...) {
  res <- .get(conn, paste0("/v3/bulk_import/show/", name))
  return(res)
}

list_bulk_imports <- function(conn) {
  res <- .get(conn, paste0("/v3/bulk_import/list"))
  return(res)
}

list_bulk_import_parts <- function(conn, name) {
  res <- .get(conn, paste0("/v3/bulk_import/list_parts/", name))
  return(res)
}

bulk_import_upload_part <- function(conn, name, part_name, file_obj) {
  .put(
    conn,
    paste0("/v3/bulk_import/upload_part/", name, "/", part_name),
    httr::upload_file(file_obj),
    file.size(file_obj)
  )
  return(TRUE)
}

bulk_import_delete_part <- function(conn, name, part_name) {
  .post(conn, paste0("/v3/bulk_import/delete_part/", name , "/", part_name), character(0))
  return(TRUE)
}

freeze_bulk_import <- function(conn, name) {
  .post(conn, paste0("/v3/bulk_import/freeze/", name), character(0))
  return(TRUE)
}

unfreeze_bulk_import <- function(conn, name) {
  .post(conn, paste0("/v3/bulk_import/freeze/", name), character(0))
  return(TRUE)
}

perform_bulk_import <- function(conn, name) {
  res <- .post(conn, paste0("/v3/bulk_import/perform/", name), character(0))
  return(res$job_id)
}

commit_bulk_import <- function(conn, name) {
  res <- .post(conn, paste0("/v3/bulk_import/commit/", name), character(0))
  return(TRUE)
}

bulk_import_error_records <- function(conn, name) {
  res <- .get(conn, paste0("/v3/bulk_import/error_records/", name))
  # TODO: uncompress gzip file and unpack msgpack
  return(res)
}

wait_bulk_import <- function(conn, sess_name) {
  status <- show_bulk_import(conn, sess_name)
  while(status$status != "committed"){
    Sys.sleep(10)
    status <- show_bulk_import(conn, sess_name)
  }
}
