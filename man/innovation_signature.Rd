% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/signatures.R
\name{innovation_signature}
\alias{innovation_signature}
\title{Extract Innovation Signature}
\usage{
innovation_signature(graph, team_graph, range_param = 2)
}
\arguments{
\item{graph}{Graph where team is part of}

\item{team_graph}{Subgraph with only team members}

\item{range_param}{A number representing how many steps away from team_graph to look, defaults to 2}
}
\value{
A number representing innovation score of team_graph
}
\description{
Extract Innovation Signature
}
