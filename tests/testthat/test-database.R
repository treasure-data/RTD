context('database')

library(mockery)
library(webmockr)

webmockr::enable()

test_that('db_list works with mock', {
  with_mock(
    `system2` = function(...) {
      c("Name	Count", "test	513094")
    }, {
      expect_equal(
        db_list(),
        dplyr::tbl_df(data.frame("Name" = "test", "Count" = 513094, stringsAsFactors = FALSE))
      )
    }
  )
})

db_list_result <- c(
  "Table	Type	Count	Schema",
  "iris	log	150	Sepal.Length:double, Sepal.Width:double, Petal.Length:double, Petal.Width:double, Species:string"
)


error_result <- character(0)
attr(error_result, "status") <- 1


test_that('db_show works with mock', {
  m <- mock(db_list_result, error_result)
  with_mock(
    `system2` = m, {
      target <- dplyr::tbl_df(
        data.frame(
          "Table" = "iris", "Type" = "log", "Count" = 150,
          "Schema" = "Sepal.Length:double, Sepal.Width:double, Petal.Length:double, Petal.Width:double, Species:string",
          stringsAsFactors = FALSE)
      )
      expect_equal(db_show("test"), target)
      # When get an error output
      expect_false(db_show("test"))
    }
  )
})


test_that('db_exists works with mock', {
  m <- mock(db_list_result, error_result)
  with_mock(
    `system2` = m, {
      expect_true(db_exists("test"))
      expect_false(db_exists("unexists"))
    }
  )
})

test_that('db_create works with mock', {
  m = mock(0, 1)
  with_mock(
    `system2` = m, {
      expect_true(db_create("test"))
      # Create existing database
      expect_false(db_create("test"))
    }
  )
})

test_that('db_delete works with mock', {
  m = mock(0, 1)
  with_mock(
    `system2` = m, {
      # Delete existing database
      expect_true(db_create("test"))
      # Delete unexisting database
      expect_false(db_create("test"))
    }
  )
})

conn <- Td(apikey = "xxxxxxx")

test_that('list_databases works with mock', {
  stub_request("get", "https://api.treasuredata.com/v3/database/list") %>%
    to_return(body =  "{\"databases\":[{\"name\":\"test\",\"created_at\":\"2011-07-23 00:00:00 UTC\",\"updated_at\":\"2011-07-23 16:32:52 UTC\",\"count\":10901115119,\"organization\":null,\"permission\":\"administrator\",\"delete_protected\":false}]}", status = 200)
  expect_true(is.data.frame(list_databases(conn)))
})

test_that('exist_databae works with mock', {
  stub_request("get", "https://api.treasuredata.com/v3/database/list") %>%
    to_return(body = "{\"databases\":[{\"name\":\"test\",\"created_at\":\"2011-07-23 00:00:00 UTC\",\"updated_at\":\"2011-07-23 16:32:52 UTC\",\"count\":10901115119,\"organization\":null,\"permission\":\"administrator\",\"delete_protected\":false}]}", status = 200)
  expect_true(exist_database(conn, 'test'))
  expect_false(exist_database(conn, 'unexist'))
})

test_that('create_database works with mock', {
  stub_request("post", "https://api.treasuredata.com/v3/database/create/test") %>%
    to_return(body = "{}", status = 200)
  expect_true(create_database(conn, "test"))
})

test_that('create_database works with mock', {
  stub_request("post", "https://api.treasuredata.com/v3/database/delete/test") %>%
    to_return(body = "{}", status = 200)
  expect_true(create_database(conn, "test"))
})
