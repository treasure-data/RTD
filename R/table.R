#' @include utilities.R
NULL

#' Describe information of a table
#'
#' @param dbname Data base name
#' @param table Table name
#' @param quiet Suppress warning for td command
#' @return A \code{list} of table info or \code{FALSE} if not exists.
#'
#' @examples
#' \dontrun{
#' table_show("mydb", "iris")
#' }
#'
#' @export
#'
table_show <- function(dbname, table, quiet = FALSE) {
  return(td_execute("table:show", c(dbname, table), quiet = quiet))
}

#' Check table existence
#'
#' @param dbname Data base name
#' @param table Table name
#' @return Returns \code{TRUE} or \code{FALSE}, existence.
#'
#' @examples
#' \dontrun{
#' table_exists("mydb", "iris")
#' }
#'
#' @export
#'
table_exists <- function(dbname, table) {
  ret <- table_show(dbname, table, quiet = TRUE)
  return(!isFALSE(ret))
}

#' Show list of tables
#'
#' @param dbname Data base name. Optional, but highly recommended to prevent timeout.
#' @param timeout Time out seconds for executing td command. It prevents long executing to list without dbname.
#' @return Returns a \code{data.frame} of a list of tables or \code{FALSE} if not exists.
#'
#' @examples
#' \dontrun{
#' # Without data base name. It might be timeout depends on the table number.
#' table_list()
#'
#' # With data base name. Recommended.
#' table_list("mydb")
#' }
#'
#' @export
#'
table_list <- function(dbname = NULL, timeout = 300) {
  return(td_execute("table:list", dbname, format = TRUE, timeout = timeout))
}

#' Create a table
#'
#' @param dbname Data base name
#' @param table Table name
#' @return Returns \code{TRUE} or \code{FALSE}, whether the executiuon successed or not.
#'
#' @examples
#' \dontrun{
#' table_create("mydb", "new_table")
#' }
#'
#' @export
#'
table_create <- function(dbname, table) {
  return(td_execute("table:create", c(dbname, table), intern = FALSE))
}

#' Delete a table
#'
#' @param dbname Data base name
#' @param table Table name
#' @return Returns \code{TRUE} or \code{FALSE}, whether the executiuon successed or not.
#'
#' @examples
#' \dontrun{
#' table_delete("mydb", "iris")
#' }
#'
#' @export
#'
table_delete <- function(dbname, table) {
  return(td_execute("table:delete", c(dbname, table, "-f"), intern = FALSE))
}
