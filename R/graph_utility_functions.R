#' Edge data to undirected
#'
#' Convert edge data to undirected edge data and count
#' number of occurances per undirected edge.
#'
#' @param data A data.frame containing two columns representing edges of a graph
#' @param from A string, specifies column with 'from' ids
#' @param to A string, specifies column with "to" ids
#'
#' @return data.frame with single row per edge of undirected graph with extra
#'   column, 'edge_count', representing number of occurances
#' @export
#' @importFrom dplyr %>% .data
#'
#' @examples
to_undirected_edges <- function(data, from, to) {
#  require(dplyr)
#  require(tidyr)

  data %>%
    dplyr::mutate(group_column  =  ifelse(.data[[from]] < .data[[to]], paste(.data[[to]], .data[[from]]),
                                   ifelse(.data[[from]] > .data[[to]], paste(.data[[from]], .data[[to]]), NA))) %>%
    dplyr::group_by(group_column) %>%
    dplyr::mutate(edge_count = dplyr::n()) %>%
    dplyr::distinct(group_column, .keep_all = TRUE) %>%
    tidyr::drop_na(group_column) %>%
    dplyr::ungroup() %>%
    dplyr::select(-group_column) %>%
    dplyr::select(dplyr::all_of(from), dplyr::all_of(to), dplyr::everything())
}


#' Get top rows by column
#'
#' Extract top 'n' rows from graphs vertices based on
#' value from 'column'
#'
#' @param graph Igraph object
#' @param column A string, specifies column for top values
#' @param n An int, specifies number of rows
#'
#' @return data.frame constisting of top values of 'column' with 'n' rows
#' @export
#'
#' @examples
get_top_by_column <- function(graph, column, n = 5) {
#  require(igraph)
#  require(dplyr)

  igraph::as_data_frame(graph, what = "vertices") %>%
  dplyr::select(dplyr::all_of(column), dplyr::everything()) %>%
  dplyr::arrange(dplyr::desc(.data[[column]])) %>%
  utils::head(n)
}

#' Friends friends subgraph
#'
#' Create a subgraph from a graph with vertices surrounding
#' input vertices with neighbouring vertices n_steps away.
#'
#' @param graph Igraph object
#' @param vertices List of strings representing vertices ids in graph
#' @param n_steps An int representing number of steps away from 'vertices'
#'
#' @return Igraph object with 'vertices' and 'n_step' neighburs
#' @export
#'
#' @examples
friends_friends <- function(graph, vertices, n_steps) {
  subgraph <- igraph::ego(graph, order = n_steps, nodes = vertices, mode = "all", mindist = 0)
  igraph::induced_subgraph(graph, unlist(subgraph))
}
