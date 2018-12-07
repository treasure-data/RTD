#' @include utilities.R
NULL

import.auto <- function(destination, file_name, delimiter, column_types, time_vealue, format='csv', header=TRUE) {
  opts <- c("--format", format, "--auto-create ", destination)
  if(header) {
    opts <- c(opts, "--column-header")
  }
  if(!missing(delimiter)) {
    opts <- c(opts, "--delimiter", delimiter)
  }
  if(!missing(column_types)) {
    opts <- c(opts, "--column-types", paste(column_types, collapse = ','))
  }
  if(!missing(time_value)) {
    opts <- c(opts, "--time-value", time_value)
  }
  opts <- c(opts, fine_name)
  
  .td.execute("import:auto", opts, intern = FALSE)
}