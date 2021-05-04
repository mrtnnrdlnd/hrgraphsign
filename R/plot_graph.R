#' Plot an igraph object
#'
#' Create a plot of an igraph object and give vertex and edge
#' style based on graph attributes.
#'
#' @param graph Graph to plot
#' @param edge_width_by A string that sets width of edge based on value from column in E(graph)
#' @param vertex_color_by A string that sets color vertex  based on value from column in V(graph)
#' @param vertex_size_by A string that sets size of vertex based on value from column in V(graph)
#'
#' @return Plotted graph
#' @export
#'
#' @examples
plot_graph <- function(graph, edge_width_by = "weights",
                       vertex_color_by = NULL,
                       vertex_size_by = NULL) {
#  require(igraph)
#  require(dplyr)
#  require(RColorBrewer)
#  require(BBmisc)

  edge_width <- igraph::edge_attr(graph, edge_width_by)

  if (!is.null(vertex_color_by)) {
    color_palette <- vertex_color_by %>%
      unique()  %>%
      length()  %>%
      RColorBrewer::brewer.pal("Set3")

    vertex_color <- color_palette[
      igraph::vertex_attr(graph, vertex_color_by) %>%
        as.factor()
    ]
  } else {vertex_color <- "gray"}

  if (!is.null(vertex_size_by)) {
    vertex_size_normalized <- igraph::vertex_attr(graph, vertex_size_by) %>%
      BBmisc::normalize(method = "range", range = c(0, 1))
    vertex_size <- ifelse(!is.na(vertex_size_normalized), (13 + 12 * vertex_size_normalized^4), 13)
  } else {vertex_size <- 13}

  plot(graph,
       edge.width = edge_width,
       vertex.color = vertex_color,
       vertex.size = vertex_size
  )
}
