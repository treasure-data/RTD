#' @include utilities.R
NULL

#' Show database list
#' @return Returns a \code{data.frame} of the database list
#'
#' @examples
#' \dontrun{
#' db_list()
#' }
#'
#' @export
#'
db_list <- function() {
  return(td_execute("db:list", format = TRUE))
}

list_databases <- function(conn) {
  res <- .get(conn, "/v3/database/list")
  return(as.data.frame(do.call("rbind", res$databases)))
}

#' Describe information of a database
#'
#' @param dbname Target data base name
#' @param quiet Suppress td command warning
#' @return Returns a \code{data.frame} of described information of a database or \code{FALSE} when the execution failed.
#'
#' @examples
#' \dontrun{
#' db_show("mydb")
#' }
#'
#' @export
db_show <- function(dbname, quiet = FALSE) {
  return(td_execute("db:show", dbname, format = TRUE, quiet = quiet))
}

#' Check table existence
#'
#' @param dbname Data base name
#' @return Return \code{TRUE} or \code{FALSE}, existence
#'
#' @examples
#' \dontrun{
#' db_exists("mydb")
#' }
#'
#' @export
#'
db_exists <- function(dbname) {
  ret <- db_show(dbname, quiet = TRUE)
  return(!isFALSE(ret))
}

exist_database <- function(conn, dbname) {
  databases <- list_databases(conn)
  return(dbname %in% databases$name)
}

#' Create a database
#'
#' @param dbname Target data base name
#' @return Returns \code{TRUE} or \code{FALSE}, whether the executiuon successed or not.
#'
#' @examples
#' \dontrun{
#' db_create("newdb")
#' }
#'
#' @export
#'
db_create <- function(dbname) {
  return(td_execute("db:create", dbname, intern = FALSE))
}

create_database <- function(conn, dbname, params, ...) {
  if(missing(params)) {
    params = character(0)
  }
  .post(conn, paste0("/v3/database/create/", dbname), params)
  return(TRUE)
}

#' Delete a database
#'
#' @param dbname Target data base name
#' @return Returns \code{TRUE} or \code{FALSE}, whether the executiuon successed or not.
#'
#' @examples
#' \dontrun{
#' db_delete("mydb")
#' }
#'
#' @export
#'
db_delete <- function(dbname) {
  return(td_execute("db:delete", c(dbname, "-f"), intern = FALSE))
}

delete_database <- function(conn, dbname) {
  .post(conn, paste0("/v3/database/delete/", dbname), character(0))
  return(TRUE)
}
