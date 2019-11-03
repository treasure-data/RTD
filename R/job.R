job_status <- function(conn, job_id) {
  res <- .get(conn, paste0("/v3/job/status/", job_id))
  return(res$status)
}

job_wait <- function(conn, job_id, wait_interval=5) {
  status <- job_status(conn, job_id)
  while(!(status %in% c("success", "error", "killed"))){
    Sys.sleep(wait_interval)
    status <- job_status(conn, job_id)
  }
}
