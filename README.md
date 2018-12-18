# RTD

[![Travis build status](https://travis-ci.org/chezou/RTD.svg?branch=master)](https://travis-ci.org/chezou/RTD)

RTD is an official R client for Arm Treasure Data. It aims to make it simple to handle or connect from R to TD.

Since RTD covers only basic execution on TD, we recommend to use RPresto or RJDBC for querying.

## Requirements

To upload data.frame from R, ensure you've installed embulk and set PATH for it.

- [embulk](https://www.embulk.org/)
- [embulk-output-td](https://github.com/treasure-data/embulk-output-td)

## Install

You can install via `devtools::install_github`.

```R
install.packages("devtools") # Install devtools if needed
devtools::install_github("chezou/RTD")
```

## Example

See also [RTD_example.Rmd](./RTD_example.Rmd) or [RPubs](https://rpubs.com/chezou/TD-from-RPresto-RTD).

```R
library(RTD)

client <- Td(apikey=Sys.getenv("TD_API_KEY"), endpoint=Sys.getenv("TD_API_SERVER"))

# Show list of databases
list_databases(client)

# Create database
create_database(client, "test")

# Craete table
create_table(client, "test", "example")

# Delete table
delete_table(client, "test", "example")

# Upload data.frame. Target database and table will be created automatically.
td_upload(client, "test", "mtcars", mtcars)

# Drop database
delete_database(client, "test")
```
