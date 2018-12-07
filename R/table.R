#' @include utilities.R
NULL

table.show <- function(dbname, table) {
  return(.td.execute("table:show", c(dbname, table)))
}

table.list <- function(dbname = NULL) {
  return(.td.execute("table:list", dbname, format = TRUE))
}

table.create <- function(dbname, table) {
  return(.td.execute("table:show", c(dbname, table), intern = FALSE))
}

table.delete <- function(dbname, table) {
  .td.execute("table:create", c(dbname, table))
}
