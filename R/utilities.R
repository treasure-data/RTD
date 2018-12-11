#' Execute td command
#'
#' @param command First argument for td command. e.g. db:list
#' @param opts Options for td command. \code{carachter} or \code{vector} of \code{character}.
#' @param format Flag for parsing td command output as TSV.
#' @param intern Flag for intern the output of system function.
#' @param quiet Suppress warning for td command.
#' @param timeout Timeout seconds for executing td command.
#'
td_execute <- function(command, opts, format = FALSE, intern = TRUE, quiet = FALSE, timeout = FALSE) {
  # Check if td command exists
  td_version()

  fmt_opt <- ifelse(format, '-f tsv', '')
  if(missing(opts)) {
    cmd <- paste(command, fmt_opt)
  } else {
    cmd <- paste(command, paste(opts, collapse = ' '), fmt_opt)
  }

  if(intern) {
    tryCatch({
      # Suppress warning for td:show checking existance of a table
      if(quiet) {
        options(warn = -1)
      }
      ret <- system2("td", cmd, stdout = TRUE, timeout = timeout)
      if(quiet) {
        options(warn = 0)
      }
      if(format) {
        return(.as.df(ret))
      }
      return(ret)
    }, error = function(err) {
      return(FALSE)
    })
  } else {
    return(system2("td", cmd))
  }
}

#' Convert td command results into data.frame
#'
#' @param input An output of td command
#'
#' @importFrom dplyr %>%
#' @importFrom readr read_tsv
#'
.as.df <- function(input) {
  return(input %>%
           paste(collapse = '\n') %>%
           read_tsv)
}

cacheEnv <- new.env(parent = emptyenv())

#' Check and cache td command version.
#'
td_version <- function() {
  if(exists("td_version", envir=cacheEnv)) {
    return(get("td_version", envir=cacheEnv))
  }

  tryCatch({
    assign("td_version", system2("td", "--version", stdout = TRUE), envir=cacheEnv)
  }, error = function(err) {
    stop("td command is not found. Please install td toolbelt or set PATH for it.")
  })

  return(cacheEnv$td_version)
}
