
#' Extract Ideation Signature
#'
#' @param graph Graph to analyze
#' @param weights Weight vector. If the graph has a weight edge attribute, then this is used by default.
#'
#' @return Igraph column with values of ideation
#' @importFrom dplyr %>% .data
#' @export
#'
#' @examples
ideation_signature <- function(graph, weights = NULL) {
  1 / graph %>%
    igraph::constraint(nodes = igraph::V(graph),
                       weights = weights) %>%
    ifelse(is.na(.) | . == 0, 1, .)
}

#' Extract Influence Signature
#'
#' @param graph Graph to analyze
#' @param weights Weight vector. If the graph has a weight edge attribute, then this is used by default.
#'
#' @return Igraph column with values of influence
#' @export
#'
#' @examples
influence_signature <- function(graph, weights = NULL, damping = 0.85) {

  if (igraph::is_directed(graph)) {
    nodes <- igraph::as_data_frame(graph, what = "vertices")
    edges <- igraph::as_data_frame(graph, what = "edges") %>%
      dplyr::mutate(temp = from, from = to, to = temp) %>%
      dplyr::select(-temp)
    graph <- igraph::graph_from_data_frame(edges, nodes,
                                           directed = TRUE)

    influence <- igraph::page_rank(graph,
                                   directed = TRUE,
                                   weights = weights,
                                   damping = damping)$vector
  } else {
    influence <- (igraph::eigen_centrality(graph,
                                           weights = weights))$vector
  }

  influence
}


#' Extract Efficiency Signature
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

  external_vertices <-
    friends_friends(graph, igraph::V(team_graph)$name, range_param) %>%
       igraph::delete_vertices(., igraph::V(team_graph)$name)

  external_range <- igraph::components(external_vertices)$no

  external_range * igraph::graph.density(team_graph)
}


#' Extract Innovation Signature
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

  team_member_islands <-
    friends_friends(graph, igraph::V(team_graph)$name, range_param) - team_graph

  no_of_team_members <- igraph::vcount(team_graph)
  no_of_external_vertices <- igraph::vcount(graph) - no_of_team_members

  external_range <- igraph::components(team_member_islands)$no

  external_range * (1 - igraph::graph.density(team_graph))
}


#' Extract Silo Signature
#'
#' This function is igraph::modularity renamed + default membership
#'
#' @param graph The input graph.
#' @param membership Vertex attribute to cluster by.
#' @param weights Weight vector. If the graph has a weight edge attribute, then this is used by default.
#'
#' @return Silo signature measure of graph (aka modularity)
#' @export
#'
#' @examples
silo_signature <- function(graph,
                           membership,
                           weights = NULL) {

  membership <- igraph::vertex_attr(graph, deparse(substitute(membership)))

  igraph::modularity(graph, factor(membership), weights = weights)
}

#' Extract Silo Quotient
#'
#' @param graph The input graph
#' @param team_graph Subgraph with only team members.
#'
#' @return A tibble with the teams silo quotients
#' @export
#'
#' @examples
silo_quotient <- function(graph,
                           team_graph) {

    internal_no_edges <- igraph::ecount(team_graph)
    external_no_edges <- igraph::ecount(friends_friends(graph, igraph::V(team_graph)$name, 1)) - internal_no_edges

    internal_no_edges / ifelse(external_no_edges > 0, external_no_edges, 1)
}

#' Extract Vulnerability Signature
#'
#' @param graph The input graph.
#' @param membership Vertex attribute to cluster by.
#' @param weights Weight vector. If the graph has a weight edge attribute, then this is used by default.
#'
#' @return A tibble of vertices with high vulnerability score
#' @export
#'
#' @examples
vulnerability_signature <- function(graph,
                                   membership,
                                   weights = NULL) {

 membership <- igraph::vertex_attr(graph, deparse(substitute(membership)))

 for (team in unique(membership)) {
   graph <- graph - igraph::induced_subgraph(graph, membership == team)
 }

 unlist(igraph::strength(graph, weights = weights))
}
