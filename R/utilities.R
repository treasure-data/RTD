library(dplyr)
library(readr)

td.execute <- function(command, opts, format = FALSE, intern = TRUE) {
  fmt_opt <- ifelse(format, '-f tsv', '')
  if(missing(opts)) {
    cmd <- paste("td", command, fmt_opt)
  } else {
    cmd <- paste("td", command, paste(opts, collapse = ' '), fmt_opt)
  }
  
  return(.as.df(system(cmd, intern = intern)))
}

.as.df <- function(input) {
  return(input %>%
           paste(collapse = '\n') %>%
           read_tsv)
}