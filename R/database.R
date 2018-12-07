#' @include utilities.R
NULL

db.list <- function() {
  return(.td.execute("db:list"), format = TRUE)
}

db.show <- function(dbname) {
  return(.td.execute("db:show", dbname, format = TRUE))
}

db.create <- function(dbname) {
  return(.td.execute("db:create", dbname, intern = FALSE))
}

