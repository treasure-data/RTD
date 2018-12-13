library(mockery)

context('table')

table_show_result <- c(
    "Name        : test.iris",
    "Type        : log",
    "Count       : 150",
    "Schema      : (",
    "    Sepal.Length:double",
    "    Sepal.Width:double",
    "    Petal.Length:double",
    "    Petal.Width:double",
    "    Species:string",
    ")"
  )

error_result <- character(0)
attr(error_result, "status") <- 1


test_that('table_list works with mock', {
  table_list_result <- c(
    "Database	Table	Type	Count	Size	Last import	Last log timestamp	Schema",
    "test	iris	log	150	0.0 GB	2018-12-13 00:23:43 +0900		Sepal.Length:double, Sepal.Width:double, Petal.Length:double, Petal.Width:double, Species:string"
  )
  expected_table_list <- dplyr::tbl_df(
    data.frame(
      "Database" = "test", "Table" = "iris", "Type" = "log", "Count" = 150,
      "Size" = "0.0 GB", "Last import" = "2018-12-13 00:23:43 +0900", "Last log timestamp" = NA,
      "Schema" = "Sepal.Length:double, Sepal.Width:double, Petal.Length:double, Petal.Width:double, Species:string",
      stringsAsFactors = FALSE, check.names = FALSE
    )
  )
  m <- mock(table_list_result, error_result)
  with_mock(
    `system2` = m, {
      expect_equal(table_list("test"), expected_table_list)
      expect_false(table_list("test"))
    }
  )
})


test_that('table_show works with mock', {
  m <- mock(table_show_result, error_result)
  with_mock(
    `system2` = m, {
      expect_equal(table_show("test", "iris"), table_show_result)
      # When get an error output
      expect_false(table_show("test", "unexists"))
    }
  )
})

test_that('table_exists works with mock', {
  m <- mock(table_show_result, error_result)
  with_mock(
    `system2` = m, {
      expect_true(table_exists("test", "iris"))
      expect_false(table_exists("test", "unexists"))
    }
  )
})

test_that('table_create works with mock', {
  m = mock(0, 1)
  with_mock(
    `system2` = m, {
      expect_true(table_create("test", "new_table"))
      # Create existing table
      expect_false(table_create("test", "new_table"))
    }
  )
})

test_that('table_delete works with mock', {
  m = mock(0, 1)
  with_mock(
    `system2` = m, {
      # Delete existing table
      expect_true(table_create("test", "iris"))
      # Delete unexisting table
      expect_false(table_create("test", "iris"))
    }
  )
})
