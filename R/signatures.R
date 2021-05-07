
#' Extract ideation signature
#'
#' @param graph Graph to analyze
#' @param weights A string that specifies attribute representing weights of the graph
#'
#' @return Igraph column with values of ideation on a scale from 1 to 10
#' @importFrom dplyr %>% .data
#' @export
#'
#' @examples
ideation_signature <- function(graph, weights = NULL) {
  1 / graph %>%
    igraph::constraint(nodes = igraph::V(graph),
                       weights = weights) %>%
    BBmisc::normalize(method = "range", range = c(0.1, 1))
}

#' Extract influence signature
#'
#' This is a fishy implementation of influence
#'
#' @param graph Graph to analyze
#' @param weights A string that specifies attribute representing weights of the graph
#'
#' @return Igraph column with values of influence on a scale from 1 to 10
#' @export
#'
#' @examples
influence_signature <- function(graph, weights = NULL) {
  if_is_directed <- igraph::is_directed(graph)

  graph_betweeness <- graph %>%
    igraph::betweenness(v = igraph::V(graph),
                        directed = if_is_directed,
                        normalized = TRUE,
                        weights = weights
                        )

  graph_eigen_centrality <- (graph %>%
    igraph::eigen_centrality(weights = weights,
                             directed = if_is_directed,
                             ))$vector

  (graph_betweeness * graph_eigen_centrality) %>%
    BBmisc::normalize(method = "range", range = c(1, 10))
}
