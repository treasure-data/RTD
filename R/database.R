NULL

#' Show database list
#' @param conn \code{Td} connection
#' @return Returns a \code{data.frame} of the database list
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxx")
#' list_databases(conn)
#' }
#'
#' @export
#'
list_databases <- function(conn) {
  res <- .get(conn, "/v3/database/list")
  return(as.data.frame(do.call("rbind", res$databases)))
}

#' Check table existence
#'
#' @param conn \code{Td} client
#' @param dbname Data base name
#' @return Return \code{TRUE} or \code{FALSE}, existence
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxx")
#' exist_database(conn, "mydb")
#' }
#'
#' @export
exist_database <- function(conn, dbname) {
  databases <- list_databases(conn)
  return(dbname %in% databases$name)
}

#' Create a database
#'
#' @param conn \code{Td} client
#' @param dbname Target data base name
#' @param params Optional parameters
#' @return Returns \code{TRUE} or \code{FALSE}, whether the execution succeeded or not.
#'
#' @examples
#' \dontrun{
#' con <- Td(apikey = "xxxxx")
#' create_database(con, "newdb")
#' }
#'
#' @export
#'
create_database <- function(conn, dbname, params) {
  if (missing(params)) {
    params <- character(0)
  }
  .post(conn, paste0("/v3/database/create/", dbname), params)
  return(TRUE)
}

#' Delete a database
#'
#' @param conn \code{Td} client
#' @param dbname Target data base name
#' @return Returns \code{TRUE} or \code{FALSE}, whether the execution succeeded or not.
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxx")
#' delete_database(conn, "mydb")
#' }
#'
#' @export
#'
delete_database <- function(conn, dbname) {
  .post(conn, paste0("/v3/database/delete/", dbname), character(0))
  return(TRUE)
}
