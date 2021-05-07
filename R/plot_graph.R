#' Plot an igraph object
#'
#' Create a plot of an igraph object and give vertex and edge
#' style based on graph attributes.
#'
#' @param graph Graph to plot
#' @param edge_width_by A string that sets width of edge based on value from attribute in graph edges
#' @param vertex_color_by A string that sets color vertex  based on value from attribute in graph vertices
#' @param vertex_size_by A string that sets size of vertex based on value from attribute in graph vertices
#'
#' @return Plotted graph
#' @export
#'
#' @examples
plot_graph <- function(graph, edge_width_by = "weights",
                       vertex_color_by = NULL,
                       vertex_size_by = NULL) {

  edge_width <- igraph::edge_attr(graph, edge_width_by)

  if (!is.null(vertex_color_by)) {
    vertex_color <- vertices_colors(graph, vertex_color_by)
  } else {vertex_color <- "gray"}

  if (!is.null(vertex_size_by)) {
    vertex_size <- vertices_sizes(graph, vertex_size_by)
  } else {vertex_size <- 10}


  plot(graph,
       edge.width = edge_width,
       vertex.color = vertex_color,
       vertex.size = vertex_size,
  )
}

#' Title
#'
#' @param graph Graph to plot
#' @param attribute A string representing vertex attribute to set color by
#' @param palette A string representing ColorBrewer palette
#'
#' @return List of colors for the vertices
#' @export
#'
#' @examples
vertices_colors <- function(graph, attribute, palette = "Set3") {
    vertices_attribute_values <- igraph::vertex_attr(graph, attribute)
    color_palette <- vertices_attribute_values %>%
      unique()  %>%
      length()  %>%
      RColorBrewer::brewer.pal(palette)

    color_palette[vertices_attribute_values %>% as.factor()]
}

#' Title
#'
#' @param graph Graph to plot
#' @param attribute A string representing vertex attribute to set color by
#' @param default_size A number representing size of 0 or NA values
#' @param scale_factor A number to scale attribute value by
#'
#' @return List of sizes for the vertices
#' @export
#'
#' @examples
vertices_sizes <- function(graph, attribute, default_size = 12, scale_factor = 1.5) {
    vertices_attribute_values <- igraph::vertex_attr(graph, attribute)
    vertex_size <- ifelse(!is.na(vertices_attribute_values),
                          (default_size + scale_factor * vertices_attribute_values),
                          default_size
    )
}
