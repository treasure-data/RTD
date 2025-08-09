context("td")

library(mockery)

con <- Td(apikey = "xxxxx")
embulk_exec <- if (.Platform$OS.type == "windows") "embulk.bat" else "embulk"

# Setup fake embulk once for all tests
setup_fake_embulk <- function() {
  # Create a temporary directory with a fake embulk
  fake_embulk_dir <- tempfile()
  dir.create(fake_embulk_dir, recursive = TRUE)

  # Create platform-specific fake embulk
  if (.Platform$OS.type == "windows") {
    fake_embulk <- file.path(fake_embulk_dir, "embulk.bat")
    writeLines("@echo off\necho fake embulk", fake_embulk)
  } else {
    fake_embulk <- file.path(fake_embulk_dir, "embulk")
    writeLines("#!/bin/bash\necho 'fake embulk'", fake_embulk)
    Sys.chmod(fake_embulk, mode = "0755")
  }

  # Temporarily modify PATH
  old_path <- Sys.getenv("PATH")
  path_sep <- if (.Platform$OS.type == "windows") ";" else ":"
  Sys.setenv(PATH = paste(fake_embulk_dir, old_path, sep = path_sep))

  # Return cleanup function
  function() {
    Sys.setenv(PATH = old_path)
    unlink(fake_embulk_dir, recursive = TRUE)
  }
}

# TODO: test for "bulk_import" mode
test_that("td_upload works with mock", {
  template_path <- system.file("extdata", "tsv_upload.yml.liquid", package = "RTD")
  m <- mock(0, 0)

  # Use local_mocked_bindings for functions that exist
  local_mocked_bindings(
    exist_database = function(...) FALSE,
    exist_table = function(...) FALSE,
    create_database = function(...) TRUE,
    create_table = function(...) TRUE,
    delete_table = function(...) TRUE,
    .package = "RTD"
  )

  # Mock tempdir to return platform-appropriate path
  temp_base <- if (.Platform$OS.type == "windows") "C:/tmp" else "/tmp"
  local_mocked_bindings(
    tempdir = function(...) temp_base,
    system2 = m,
    .package = "base"
  )

  local_mocked_bindings(
    write_tsv = function(...) TRUE,
    .package = "readr"
  )

  # Setup fake embulk and ensure cleanup
  cleanup_embulk <- setup_fake_embulk()
  on.exit(cleanup_embulk())

  td_upload(con, "test", "iris", iris, mode = "embulk")
  expect_args(m, 1, embulk_exec, paste("guess", template_path, paste0("-o ", temp_base, "/load.yml")))
  expect_args(m, 2, embulk_exec, paste0("run ", temp_base, "/load.yml"))
})

test_that("td_upload works with mock when the table already exists", {
  template_path <- system.file("extdata", "tsv_upload.yml.liquid", package = "RTD")
  m <- mock(0, 0)

  # Use local_mocked_bindings for functions that exist
  local_mocked_bindings(
    exist_database = function(...) FALSE,
    exist_table = function(...) TRUE,
    create_database = function(...) TRUE,
    create_table = function(...) TRUE,
    delete_table = function(...) TRUE,
    .package = "RTD"
  )

  # Mock tempdir to return platform-appropriate path
  temp_base <- if (.Platform$OS.type == "windows") "C:/tmp" else "/tmp"
  local_mocked_bindings(
    tempdir = function(...) temp_base,
    system2 = m,
    .package = "base"
  )

  local_mocked_bindings(
    write_tsv = function(...) TRUE,
    .package = "readr"
  )

  # Setup fake embulk and ensure cleanup
  cleanup_embulk <- setup_fake_embulk()
  on.exit(cleanup_embulk())

  expect_error(td_upload(con, "test", "iris", iris), ".* already exists.")
  td_upload(con, "test", "iris", iris, mode = "embulk", overwrite = TRUE)
  expect_args(m, 1, embulk_exec, paste("guess", template_path, paste0("-o ", temp_base, "/load.yml")))
  expect_args(m, 2, embulk_exec, paste0("run ", temp_base, "/load.yml"))
})
