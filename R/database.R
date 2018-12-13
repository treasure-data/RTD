#' @include utilities.R
NULL

#' Show database list
#' @export
#'
db_list <- function() {
  return(td_execute("db:list", format = TRUE))
}

#' Describe information of a database
#'
#' @param dbname Target data base name
#' @param quiet Suppress td command warning
#'
#' @export
db_show <- function(dbname, quiet = FALSE) {
  return(td_execute("db:show", dbname, format = TRUE, quiet = quiet))
}

#' Check table existence
#'
#' @param dbname Data base name
#'
#' @export
#'
db_exists <- function(dbname) {
  ret <- db_show(dbname, quiet = TRUE)
  return(!isFALSE(ret))
}

#' Create a database
#'
#' @param dbname Target data base name
#'
#' @export
#'
db_create <- function(dbname) {
  return(td_execute("db:create", dbname, intern = FALSE))
}

#' Delete a database
#'
#' @param dbname Target data base name
#'
#' @export
#'
db_delete <- function(dbname) {
  return(td_execute("db:delete", c(dbname, "-f"), intern = FALSE))
}
