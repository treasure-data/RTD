library(mockery)

context('import')

current_time = 1544680800
test_time <- as.POSIXlt("2018-12-13 15:00:00 JST")

test_that('import_auto works with mock', {
  m <- mock(0)
  with_mock(
    `system2` = m,
    {
      import_auto(
        "test.iris",
        "iris.tsv",
        time_value = current_time,
        header = TRUE
      )
    }
  )

  expect_args(m, TRUE, "td", "import:auto --format tsv --auto-create  test.iris --column-header --time-value 1544680800 iris.tsv ")
})

test_that('import_auto works with mock without time_value', {
  m <- mock(0)
  with_mock(
    `system2` = m,
    `Sys.time` = mock(test_time),
    {
      import_auto(
        "test.iris",
        "iris",
        format = "csv"
      )
    }
  )

  expect_args(m, TRUE, "td", "import:auto --format csv --auto-create  test.iris --column-header --time-value 1544680800 iris ")
})

