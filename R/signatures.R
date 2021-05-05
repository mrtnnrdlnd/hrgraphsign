
#' Extract ideation signature
#'
#' @param graph Graph to analyze
#' @param weights A string that specifies attribute representing weights of the graph
#'
#' @return Igraph column with values of ideation on a scale from 1 to 10
#' @export
#'
#' @examples
ideation_signature <- function(graph, weights = "weights") {
  1/graph %>%
    igraph::constraint(nodes = igraph::V(graph),
                       weights = igraph::edge_attr(graph, weights)) %>%
    BBmisc::normalize(method = "range", range = c(0.1, 1))
}

#' Extract influence signature
#'
#' @param graph Graph to analyze
#' @param weights A string that specifies attribute representing weights of the graph
#'
#' @return Igraph column with values of influence on a scale from 1 to 10
#' @export
#'
#' @examples
influence_signature <- function(graph, weights = "weights") {
  igraph::betweenness(
    graph,
    v = igraph::V(graph),
    directed = FALSE,
    weights = igraph::edge_attr(graph, weights),
  ) %>%
  BBmisc::normalize(method = "range", range = c(1, 10))
}
