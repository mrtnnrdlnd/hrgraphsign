#' Graph To Undirected
#'
#' @param graph Graph to make undirected
#'
#' @return Undirected graph
#' @export
#'
#' @examples
aggregate_edges <- function(graph) {
  igraph::E(graph)$weights <- igraph::count_multiple(graph)
  graph <- igraph::simplify(graph, remove.loops = TRUE, edge.attr.comb = "first")
  return(graph)
}



#' Get Top Rows By Column
#'
#' Extract top \code{n} rows from graphs vertices based on
#' value from \code{column}
#'
#' @param graph Igraph object
#' @param column A string that specifies column for top values
#' @param n A number that specifies number of rows
#'
#' @return data.frame consisting of top values of \code{column} with \code{n} rows
#' @export
#'
#' @examples
get_top_by_column <- function(graph, column, n = 5) {

  igraph::as_data_frame(graph, what = "vertices") %>%
  dplyr::select(dplyr::all_of(column), dplyr::everything()) %>%
  dplyr::arrange(dplyr::desc(.data[[column]])) %>%
  utils::head(n)
}

#' Friends friends subgraph
#'
#' Create a subgraph from a graph with vertices surrounding
#' input \code{vertices} with neighbouring vertices \code{n_steps} away.
#'
#' @param graph Igraph object
#' @param vertices List of strings representing vertices ids in graph
#' @param n_steps An int representing number of steps away from 'vertices'
#'
#' @return Igraph object with 'vertices' and 'n_step' neighbours
#' @export
#'
#' @examples
friends_friends <- function(graph, vertices, n_steps) {
  subgraph <- igraph::ego(graph, order = n_steps, nodes = vertices, mode = "all", mindist = 0)
  igraph::induced_subgraph(graph, unlist(subgraph))
}
