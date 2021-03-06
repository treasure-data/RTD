% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/table.R
\name{exist_table}
\alias{exist_table}
\title{Check table existence}
\usage{
exist_table(conn, dbname, table)
}
\arguments{
\item{conn}{\code{Td} connection}

\item{dbname}{Data base name}

\item{table}{Table name}
}
\value{
Returns \code{TRUE} or \code{FALSE}, existence.
}
\description{
Check table existence
}
\examples{
\dontrun{
conn <- Td(apikey = "xxxxx")
exist_table(conn, "mydb", "iris")
}

}
