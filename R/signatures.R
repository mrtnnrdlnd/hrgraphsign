
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
    BBmisc::normalize(method = "range", range = c(0.1, 1)) %>%
    ifelse(is.na(.), 1, .)
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


#' Extract efficiency signature
#'
#' @param graph Graph where team is part of
#' @param team_graph Subgraph with only team members
#' @param range_param A number representing how many steps away from team_graph to look, defaults to 2
#'
#' @return A number representing efficiency score of team_graph
#' @export
#'
#' @examples
efficiency_signature <- function(graph, team_graph, range_param = 2) {

  external_range <-
    (friends_friends(graph, igraph::V(team_graph)$name, range_param) %>%
       igraph::delete_vertices(., igraph::V(team_graph)$name) %>%
       igraph::components(.))$no

  external_range / igraph::vcount(team_graph) * igraph::graph.density(team_graph)
}


#' Extract innovation signature
#'
#' @param graph Graph where team is part of
#' @param team_graph Subgraph with only team members
#' @param range_param A number representing how many steps away from team_graph to look, defaults to 2
#'
#' @return A number representing innovation score of team_graph
#' @export
#'
#' @examples
innovation_signature <- function(graph, team_graph, range_param = 2) {

  islands <-
    friends_friends(graph, igraph::V(team_graph)$name, range_param) %>%
       igraph::delete_edges(., igraph::V(team_graph)$name)

  external_range <- igraph::components(islands)$no * (igraph::vcount(islands) - igraph::vcount(team_graph))

  external_range / igraph::vcount(team_graph) / igraph::graph.density(team_graph)
}

#' Extract silo signature
#'
#' This function is igraph::modularity renamed + default membership set to cluster_fast_greedy
#'
#' @param graph The input graph.
#' @param membership Numeric vector, for each vertex it gives its community. The communities are numbered from one.
#' @param weights If not NULL then a numeric vector giving edge weights.
#'
#' @return Silo signature measure (aka modularity)
#' @export
#'
#' @examples
silo_signature <- function(graph,
                           membership = igraph::cluster_fast_greedy(igraph::as.undirected(graph))$membership,
                           weights = NULL) {

  igraph::modularity(graph, factor(membership))
}
