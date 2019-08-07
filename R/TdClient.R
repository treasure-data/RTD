
TdClient <- setRefClass(
  "TdClient",
  fields = list(
    endpoint="character", apikey="character",
    user_agent="character", headers="character",
    http_proxy="character"))

DEFAULT_ENDPOINT <- "api.treasuredata.com"

#' Connect to TD
#'
#' @param endpoint Endpoint to TD API
#' @param apikey API key for TD
#' @param user_agent User-Agent as \code{character}. optional
#' @param headers Default headres in a named \code{character} vector. optional
#' @param http_proxy HTTP proxy setting. optional.
#'
#' @importFrom methods new
#' @importFrom utils packageVersion
#'
#' @examples
#' \dontrun{
#' client <- Td(
#'   endpoint="api.treasuredata.com",
#'   apikey="xxxxxx",
#'   http_proxy="http://user:pass@proxy.domain.com:8080/")
#' }
#'
#' @export
Td <- function(endpoint, apikey, user_agent, headers, http_proxy=NULL) {
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
  endpoint <- urltools::url_parse(endpoint)$domain
  if(missing(user_agent)) {
    user_agent = paste0("RTD/", packageVersion("RTD"))
  }
  if(missing(headers)) {
    headers <- character(0)
  }
  if(is.null(http_proxy)){
    env_proxy <- Sys.getenv("HTTP_PROXY")
    if(nzchar(env_proxy)) {
      http_proxy <- env_proxy
    }
  }
  proxy_settings <- character(0)
  if(!is.null(http_proxy)) {
    parsed_url <- urltools::url_parse(http_proxy)

    credentials <- urltools::get_credentials(http_proxy)
    username <- if(is.na(credentials$username)) NULL else credentials$username
    password <- if(is.na(credentials$authentication)) NULL else credentials$authentication

    # Setting for embulk
    proxy_settings <- c(
      host = parsed_url$domain, port = parsed_url$port,
      use_ssl = tolower(parsed_url$scheme == 'https'), user = username, password = password)

    # Set config for httr
    httr::set_config(httr::use_proxy(
      paste(parsed_url$scheme, parsed_url$domain, sep = "://"),
      port = as.integer(parsed_url$port),
      username = username,
      password = password
      ))
  }

  con <- TdClient$new(
      endpoint=endpoint,
      apikey=apikey,
      user_agent=user_agent,
      headers=headers,
      http_proxy=proxy_settings
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

check_status_code <- function(response) {
  status <- httr::status_code(response)
  if (status >= 400 && status < 500) {
    content <- httr::content(response, as = "text", encoding='UTF-8')
    if (is.null(content) || !nzchar(content)) {
      httr::stop_for_status(status)
    }
    stop('Received error response (HTTP ', status, '): ', content)
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
  check_status_code(response)
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
  check_status_code(response)
  content <- httr::content(response, as = "text", encoding ="UTF-8")
  jsonlite::fromJSON(content, simplifyVector = FALSE)
}

