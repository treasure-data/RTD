
TdClient <- setRefClass("TdClient", fields = list(endpoint="character", apikey="character", user_agent="character", headers="character"))

DEFAULT_ENDPOINT <- "api.treasuredata.com"

#' Td client
#'
#' @param endpoint Endpoint to TD API
#' @param apikey API key for TD
#' @param user_agent User-Agent. optional
#' @param headers Default headres. optional
#'
#' @importFrom methods new
#' @importFrom utils packageVersion
#'
#' @export
Td <- function(endpoint, apikey, user_agent, headers) {
  if(missing(apikey)) {
    apikey = Sys.getenv("TD_API_KEY")

    if(apikey == '') {
      stop("No API key given.")
    }
  }
  if(missing(endpoint)) {
    endpoint = Sys.getenv("TD_API_SERVER")

    if(endpoint == '') {
      endpoint <- DEFAULT_ENDPOINT
    }
  }
  if(missing(user_agent)) {
    user_agent = paste0("RTD/", packageVersion("RTD"))
  }
  if(missing(headers)) {
    headers <- character(0)
  }

  con <- TdClient$new(
      endpoint=endpoint,
      apikey=apikey,
      user_agent=user_agent,
      headers=headers
    )
  return(con)
}

.request_headers <- function(conn, headers=NULL) {
  return(httr::add_headers(
    "User-Agent" = conn$user_agent,
    "Authorization" = paste("TD1", conn$apikey),
    # RFC2822 style formatpa
    "Date" = strftime(Sys.time(), format="%a, %d %b %Y %H:%M:%S -0000", tz="UTC", use.tz = TRUE),
    headers
  ))
}

.build_request <- function(conn, path, headers=NULL) {
  if(missing(path)){
    url <- conn$endpoint
  } else {
    url <- paste0('https://', conn$endpoint, path)
  }
  headers <- .request_headers(conn, headers)
  return(list("url"=url, "headers"=headers))
}

wait <- function () {
  # sleep 50 - 100 ms
  Sys.sleep(stats::runif(n = 1, min = 50, max = 100) / 1000)
}

check.status.code <- function(response) {
  status <- httr::status_code(response)
  if (status >= 400 && status < 500) {
    text.content <- httr::content(response, as = "text", encoding='UTF-8')
    if (is.null(text.content) || !nzchar(text.content)) {
      httr::stop_for_status(status)
    }
    stop('Received error response (HTTP ', status, '): ', text.content)
  }
}

.get <- function(conn, path, headers=NULL, ...) {
  req <- .build_request(conn, path=path, headers=headers, ...)
  status <- 503L
  retries <- 3
  while (status == 503L || (retries > 0 && status >= 400L)) {
    wait()
    response <- httr::GET(req$url, req$headers)
    status <- as.integer(httr::status_code(response))
    if (status >= 400L && status != 503L) {
      retries <- retries - 1
    }
  }
  check.status.code(response)
  content <- httr::content(response, as = "text", encoding ="UTF-8")
  jsonlite::fromJSON(content, simplifyVector = FALSE)
}

.post <- function(conn, path, params, headers=NULL, ...) {
  req <- .build_request(conn, path=path, headers=headers, ...)
  status <- 503L
  retries <- 3
  while (status == 503L || (retries > 0 && status >= 400L)) {
    wait()
    response <- httr::POST(req$url, body=enc2utf8(params), req$headers)
    status <- as.integer(httr::status_code(response))
    if (status >= 400L && status != 503L) {
      retries <- retries - 1
    }
  }
  check.status.code(response)
  content <- httr::content(response, as = "text", encoding ="UTF-8")
  jsonlite::fromJSON(content, simplifyVector = FALSE)
}

.post <- function(conn, path, params, headers=NULL, ...) {
  req <- .build_request(conn, path=path, headers=headers, ...)
  status <- 503L
  retries <- 3
  while (status == 503L || (retries > 0 && status >= 400L)) {
    wait()
    response <- httr::POST(req$url, body=enc2utf8(params), req$headers)
    status <- as.integer(httr::status_code(response))
    if (status >= 400L && status != 503L) {
      retries <- retries - 1
    }
  }
  check.status.code(response)
  content <- httr::content(response, as = "text", encoding ="UTF-8")
  jsonlite::fromJSON(content, simplifyVector = FALSE)
}
