#' Check msgpack package installed or not
#'
#' If msgpack package is not installed, install it from GitHub using
#' devtools. If it is not up to date, reinstall it.
#' @export
check_msgpack <- function() {
  msgpack_version <- "1.0.1"
  if (!requireNamespace("msgpack", quietly = TRUE)) {
    message("msgpack package must be installed.")
    install_msgpack()
  } else if (utils::packageVersion("msgpack") < msgpack_version) {
    message("msgpack package must be updated.")
    install_msgpack()
  }
}

#' Install the msgpack package after checking with the user
#' @export
install_msgpack <- function() {
  instructions <- paste(" Please install the package for yourself",
                        "using the following command: \n",
                        "    install.packages(\"devtools\")\n",
                        "    devtools::install_github(\"crowding/msgpack-r\")")

  error_func <- function(e) {
    stop(paste("Failed to install the msgpack package.\n", instructions))
  }

  input <- 1
  if (interactive()) {
    input <- utils::menu(c("Yes", "No"),
                         title = "Install msgpack package?")
  }

  if (input == 1) {
    if (!requireNamespace("devtools", quietly = TRUE)) {
      message("devtools package needs to be installed.\n",
              "Installing devtools from CRAN")
      tryCatch(utils::install.packages("devtools"),
               error = error_func, warning = error_func)
    }
    message("Installing msgpack package.")
    tryCatch(devtools::install_github("crowding/msgpack-r"),
             error = error_func, warning = error_func)
  } else {
    stop(paste("msgpack package is necessary for that method.\n",
               instructions))
  }
}
