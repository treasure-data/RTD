context('table')

library(mockery)
library(webmockr)

webmockr::enable()

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


conn <- Td(apikey = "xxxxxxx")

test_that('list_tables works with mock', {
  stub_request("get", "https://api.treasuredata.com/v3/table/list/sample_datasets") %>%
    to_return(body = '{"tables":[
  {"id":210906,"name":"nasdaq","estimated_storage_size":168205061,"counter_updated_at":null,"last_log_timestamp":null,"type":"log","count":8807278,"expire_days":null,"created_at":"2014-10-08 02:57:38 UTC","updated_at":"2014-10-08 03:16:59 UTC","schema":"[]"},
  {"id":208715,"name":"www_access","estimated_storage_size":0,"counter_updated_at":"2014-10-04T01:13:20Z","last_log_timestamp":"2014-10-04T01:13:15Z","type":"log","count":5000,"expire_days":null,"created_at":"2014-10-04 01:13:12 UTC","updated_at":"2014-10-22 07:02:19 UTC","schema":"[]"}
  ],
  "database":"sample_datasets"
}', status = 200)
  tables <- list_tables(conn, "sample_datasets")
  expect_equal(dplyr::count(tables)$n, 2)
})

test_that('exist_table works with mock', {
  stub_request("get", "https://api.treasuredata.com/v3/table/list/sample_datasets") %>%
    to_return(body = '{"tables":[
              {"id":210906,"name":"nasdaq","estimated_storage_size":168205061,"counter_updated_at":null,"last_log_timestamp":null,"type":"log","count":8807278,"expire_days":null,"created_at":"2014-10-08 02:57:38 UTC","updated_at":"2014-10-08 03:16:59 UTC","schema":"[]"},
              {"id":208715,"name":"www_access","estimated_storage_size":0,"counter_updated_at":"2014-10-04T01:13:20Z","last_log_timestamp":"2014-10-04T01:13:15Z","type":"log","count":5000,"expire_days":null,"created_at":"2014-10-04 01:13:12 UTC","updated_at":"2014-10-22 07:02:19 UTC","schema":"[]"}
              ],
              "database":"sample_datasets"
}', status = 200)
  expect_true(exist_table(conn, 'sample_datasets', 'nasdaq'))
  expect_false(exist_table(conn, 'sample_datasets', 'unexist'))
})

test_that('create_table works with mock', {
  stub_request("post", "https://api.treasuredata.com/v3/table/create/sample_datasets/test/log") %>%
    to_return(body = "{}", status = 200)
  expect_true(create_table(conn, "sample_datasets", "test"))
})

test_that('delete_table works with mock', {
  stub_request("post", "https://api.treasuredata.com/v3/table/delete/sample_datasets/test") %>%
    to_return(body = '{"type": "log"}', status = 200)
  expect_equal(delete_table(conn, "sample_datasets", "test"), "log")
})
