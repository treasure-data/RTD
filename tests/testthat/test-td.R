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
  expect_args(m, TRUE, "td", "import:auto --format tsv --auto-create  test.iris --column-header --time-value 1544713200 /tmp/filed7ff398c8e.tsv ")
})
