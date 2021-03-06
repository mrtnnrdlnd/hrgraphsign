% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/graph_utility_functions.R
\name{get_top_by_column}
\alias{get_top_by_column}
\title{Get Top Rows By Column}
\usage{
get_top_by_column(graph, column, n = 5)
}
\arguments{
\item{graph}{Igraph object}

\item{column}{A string that specifies column for top values}

\item{n}{A number that specifies number of rows}
}
\value{
data.frame consisting of top values of \code{column} with \code{n} rows
}
\description{
Extract top \code{n} rows from graphs vertices based on
value from \code{column}
}
