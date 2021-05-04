
#' Extract ideation signature
#'
#' @param graph Graph to analyze
#' @param weights A string that specifies column representing weights of the graph
#'
#' @return Igraph column with values of ideation
#' @export
#'
#' @examples
ideation_signature <- function(graph, weights = "weights") {
  1 - igraph::constraint(graph, nodes = igraph::V(graph),
                     weights = igraph::edge_attr(graph, weights))
}
