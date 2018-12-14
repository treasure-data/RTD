#' @include import.R table.R
NULL

#' Upload data.frame to TD
#'
#' @param dbname Target destination database name.
#' @param table Target table name.
#' @param df Input data.frame.
#' @param overwrite Flag for overwriting the table if exists. It doesn't overwrite database.
#'
#' @examples
#' \dontrun{
#' td_upload("mydb", "iris", iris)
#'
#' # With overwrite option
#' td_upload("mydb", "iris", iris, overwrite = TRUE)
#' }
#'
#' @importFrom readr write_tsv
#' @export
td_upload <- function(dbname, table, df, overwrite = FALSE) {
  exists_db <- db_exists(dbname)
  exists_table <- table_exists(dbname, table)
  if(!overwrite && exists_table) {
    stop(paste0('"', dbname, ".", table, '" is already exists.'))
  }
  if(!exists_db) {
    db_create(dbname)
  }
  if(overwrite && exists_table) {
    table_delete(dbname, table)
  }
  table_create(dbname, table)

  column_types <- .guess_column_types(df)

  tmpfname <- tempfile(fileext = ".tsv")

  write_tsv(df, tmpfname, quote_escape = FALSE, na = '')
  import_auto(paste(dbname, table, sep = '.'), tmpfname, format = 'tsv', column_types = column_types)
}

.guess_column_types <- function(df) {
  guessed_types <- sapply(df, function(x){
    if(is.factor(x) || is.character(x)) {
      "string"
    } else if(all(x%%1 == 0)) {
      "int"
    } else {
      "double"
    }
  })

  return(paste(guessed_types, collapse = ','))
}
