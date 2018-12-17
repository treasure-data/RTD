library(mockery)

context('td')

test_that("td_upload works with mock",{
  test_time <- as.POSIXlt("2018-12-13 15:00:00", tz="GMT")
  m <- mock(0)
  with_mock(
    db_exists = mock(FALSE),
    table_exists = mock(FALSE),
    db_create = mock(TRUE),
    table_create = mock(TRUE),
    table_delete = mock(TRUE),
    tempfile = mock("/tmp/filed7ff398c8e.tsv"),
    `Sys.time` = mock(test_time),
    `system2` = m,
    {
      td_upload("test", "iris", iris)
    }
  )
  expect_args(m, TRUE, "td", "import:auto --format tsv --auto-create test.iris --column-header --column-types double,double,double,double,string --time-value 1544713200 /tmp/filed7ff398c8e.tsv")
})



test_that("td_upload_embulk works with mock",{
  test_time <- as.POSIXlt("2018-12-13 15:00:00", tz="GMT")
  template_path <- system.file("extdata", "tsv_upload.yml.liquid", package="RTD")
  m <- mock(0, 0)
  with_mock(
    db_exists = mock(FALSE),
    table_exists = mock(FALSE),
    db_create = mock(TRUE),
    table_create = mock(TRUE),
    table_delete = mock(TRUE),
    tempdir = mock("/tmp"),
    #`system.file` = mock("/home/R/package/RTD/extdata/tsv_upload.yml.liquid"),
    `Sys.which` = mock("/home/RTD/bin/embulk"),
    `Sys.time` = mock(test_time),
    `system2` = m,
    {
      td_upload_embulk("test", "iris", iris)
    }
  )
  expect_args(m, 1, "embulk", paste("guess", template_path, "-o /tmp/load.yml"))
  expect_args(m, 2, "embulk", "run /tmp/load.yml")
})
