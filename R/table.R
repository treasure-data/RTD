#' @include utilities.R
NULL

#' Describe information of a table
#'
#' @param dbname Data base name
#' @param table Table name
#' @param quiet Suppress warning for td command
#'
#' @export
#'
table_show <- function(dbname, table, quiet = FALSE) {
  return(td_execute("table:show", c(dbname, table), quiet = quiet))
}

#' Check table existance
#'
#' @param dbname Data base name
#' @param table Table name
#'
#' @export
#'
table_exists <- function(dbname, table) {
  ret <- table_show(dbname, table, quiet = TRUE)
  return(!isFALSE(ret))
}

#' Show list of tables
#'
#' @param dbname Data base name. Optional.
#'
#' @export
#'
table_list <- function(dbname = NULL) {
  return(td_execute("table:list", dbname, format = TRUE))
}

#' Create a table
#'
#' @param dbname Data base name
#' @param table Table name
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
#'
#' @export
#'
table_delete <- function(dbname, table) {
  return(td_execute("table:delete", c(dbname, table, "-f"), intern = FALSE))
}
