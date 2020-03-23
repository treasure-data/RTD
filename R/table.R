#' @include TdClient.R
NULL


#' Check table existence
#'
#' @param conn \code{Td} connection
#' @param dbname Data base name
#' @param table Table name
#' @return Returns \code{TRUE} or \code{FALSE}, existence.
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxxx")
#' exist_table(conn, "mydb", "iris")
#' }
#'
#' @export
#'
exist_table <- function(conn, dbname, table) {
  tables <- list_tables(conn, dbname)
  return(table %in% tables$name)
}

#' Show list of tables
#'
#' @param conn \code{Td} connection
#' @param dbname Data base name. Optional, but highly recommended to prevent timeout.
#' @return Returns a \code{data.frame} of a list of tables or \code{FALSE} if not exists.
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxxx")
#' list_tables(conn, "mydb")
#' }
#'
#' @export
#'
list_tables <- function(conn, dbname) {
  res <- .get(conn, paste0("/v3/table/list/", dbname))
  return(dplyr::tibble(as.data.frame(do.call("rbind", res$tables))))
}


#' Create a table
#'
#' @param conn \code{Td} connection
#' @param dbname Data base name
#' @param table Table name
#' @return Returns \code{TRUE} or \code{FALSE}, whether the execution succeeded or not.
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxx")
#' create_table(conn, "mydb", "new_table")
#' }
#'
#' @export
#'
create_table <- function(conn, dbname, table) {
  .post(conn, paste0("/v3/table/create/", dbname, "/", table, "/log"), character(0))
  return(TRUE)
}

#' Delete a table
#'
#' @param conn \code{Td} connection
#' @param dbname Data base name
#' @param table Table name
#' @return Returns \code{TRUE} or \code{FALSE}, whether the execution succeeded or not.
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxxx")
#' delete_table(conn, "mydb", "iris")
#' }
#'
#' @export
#'
delete_table <- function(conn, dbname, table) {
  res <- .post(conn, paste0("/v3/table/delete/", dbname, "/", table), character(0))
  return(TRUE)
}

#' Update schema of a table
#'
#' @param conn \code{Td} connection
#' @param dbname Data base name
#' @param table Table name
#' @param schema Schema of the table to be updated
#' @return Returns \code{TRUE} or \code{FALSE}, whether the execution succeeded or not.
#'
#' @examples
#' \dontrun{
#' conn <- Td(apikey = "xxxxx")
#' s <- rbind(
#' c("sepal_length", "double", "sepal_length"),
#' c("sepal_width", "double", "sepal_width"),
#' c("petal_length", "double", "petal_length"),
#' c("petal_width", "double", "petal_width"),
#' c("species", "string", "species"))
#' udpate_schema(conn, "mydb", "iris", s)
#' }
#'
#' @export
#'
update_schema <- function(conn, dbname, table, schema) {
  res <- .post(conn, paste0("/v3/table/update-schema/", dbname, "/", table), query=paste0("schema=", jsonlite::toJSON(schema)))
  return(TRUE)
}
