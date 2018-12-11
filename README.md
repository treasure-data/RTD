# RTD

RTD is an official R client for Arm Treasure Data. It aims to make it simple to handle or connect from R to TD.

Since RTD covers only basic execution on TD, we recommend to use RPresto or RJDBC for querying.

## Requirements

Since current implementation is a simple wrapper of TD toolbelt. Ensure you've installed TD toolbelt and set PATH for it.

- [TD toolbelt](https://toolbelt.treasuredata.com/)

## Install

You can install via `devtools::install_github`.

```R
install.packages("devtools") # Install devtools if needed
devtools::install_github("chezou/RTD")
```

## Example

```R
library(RTD)

# Show list of databases
db_list()

# Show specific database information
db_show("sample_datasets")

# Create database
db_create("test")

# Craete table
table_create("test", "example")

# Import TSV file
import_auto("test.example", "example.tsv", header = TRUE)

# Delete table
table_delete("test", "example")

# Upload data.frame. Target database and table will be created automatically.
td_upload("test", "mtcars", mtcars)

# Drop database
db_delete("test")
```
