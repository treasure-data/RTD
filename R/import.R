#' @include utilities.R
NULL

#' Import file to TD. Equivalent with td import:auto
#'
#' @param dest Destination for TD. `db_name.table_name`
#' @param file_name Input file name to upload
#' @param column_types column types [string, int, long, double]
#' @param time_value time column's value.
#' @param format source file format [csv, tsv, json, msgpack, apache, regex, mysql]; default=csv
#' @param delimiter CSV/TSV option. delimiter CHAR; default="," at csv, TAB at tsv
#' @param header CSV/TSV option. first line includes column names
#' @param quote CSV/TSV option. [DOUBLE, SINGLE, NONE]; if csv format, default=DOUBLE. if tsv format, default=NONE
#' @export
#'
import_auto <- function(
    dest,
    file_name,
    delimiter,
    column_types,
    time_value,
    format,
    header = TRUE,
    quote
  ) {

  # Guess format from file extension if format missing. Default is 'csv'
  if(missing(format)) {
    ext <- tolower(tools::file_ext(file_name))
    format <- switch(ext,
      'csv' = 'csv',
      'tsv' = 'tsv',
      'json' = 'json',
      'csv'
    )
  }
  opts <- c("--format", format, "--auto-create ", dest)
  if(header) {
    opts <- c(opts, "--column-header")
  }
  if(!missing(delimiter)) {
    opts <- c(opts, "--delimiter", delimiter)
  }
  if(!missing(column_types)) {
    opts <- c(opts, "--column-types", paste(column_types, collapse = ','))
  }
  if(!missing(quote)) {
    opts <- c(opts, "--quote", quote)
  }
  if(missing(time_value)) {
    time_value <- round(as.numeric(Sys.time()))
  }
  opts <- c(opts, "--time-value", time_value)
  opts <- c(opts, file_name)

  td_execute("import:auto", opts, intern = FALSE)
}
