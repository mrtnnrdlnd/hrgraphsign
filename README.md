
# hrgraphsign

    Simplifies analysis of hr-graph data based on the six signatures
    from this article: https://hbr.org/2018/11/better-people-analytics

## Installation

    devtools::install_github("mrtnnrdlnd/hrgraphsign")

## Background

There are measures of employees performance which can’t be measured in
isolation. Six of these measures are mentioned in the article:

> **Better People Analytics** Measure who they know, not just who they
> are. **by Paul Leonardi and Noshir Contractor**

This package is an attempt to make these six measures a little easier to
use in practice. The measures is referred to as signatures in the
article and so they will be here. They are, in order of appearance:

1.  **Ideation Signature** - Individual level measure
2.  **Influence Signature** - Individual level measure
3.  **Efficiency Signature** - Team level measure
4.  **innovation Signature** - Team level measure
5.  **Silo Signature** - Organizational level measure
6.  **Vulnerability Signature** Organizational level measure

## The Signatures by example

Before getting to the actual signatures we load some example data and
create a connected network from it

### Example Data

``` r
# nodes will be representing the employees
nodes <- readxl::read_excel("example/nodes.xlsx")
# Look at data
knitr::kable(nodes %>% head(5))
```

|  ID | firstName | lastName | title | department | employmentYear |
|----:|:----------|:---------|:------|:-----------|---------------:|
|   1 | adolf     | albano   | NA    | Sales      |           2014 |
|   2 | benny     | bop      | NA    | Sales      |           2012 |
|   3 | cristine  | cristal  | NA    | Sales      |           2017 |
|   4 | dan       | damp     | NA    | Sales      |           2015 |
|   5 | egil      | efraheim | NA    | Sales      |           2017 |

``` r
# edges will be representing the relations between the employees
edges <- readxl::read_excel("example/edges.xlsx")
# Look at data
knitr::kable(edges %>% head(5))
```

| date       | FromID | ToID | medium  |  …5 |  …6 |
|:-----------|-------:|-----:|:--------|----:|----:|
| 2021-04-19 |      4 |    6 | email   |   1 |  10 |
| 2021-04-20 |      5 |    8 | meeting |   1 |  10 |
| 2021-04-21 |      6 |    6 | meeting |   1 |  10 |
| 2021-04-22 |      1 |    8 | email   |   1 |  10 |
| 2021-04-23 |      6 |    4 | email   |   1 |  10 |

### Create Graph

``` r
example_graph <- edges %>% 
  dplyr::select(FromID, ToID, everything()) %>%
  igraph::graph_from_data_frame(directed = FALSE, vertices = nodes) %>% 
  hrgraphsign::aggregate_edges()
```

### Individual level

#### Ideation Signature

Predicts, according to the article, which employees will come up with
good ideas.

The ideation signature is measured by having a low value of something
called Burt’s constraint, named after Ronald Stuart Burt. It looks at
how widespread connections and how much connections to different groups
a person has.

``` r
# Get ideation measure
igraph::V(example_graph)$ideation <- hrgraphsign::ideation_signature(example_graph)
# Display Top 3 For Ideation
knitr::kable(hrgraphsign::get_top_by_column(example_graph, column = "ideation", n = 3))
```

|     | ideation | name | firstName | lastName | title | department  | employmentYear |
|:----|---------:|:-----|:----------|:---------|:------|:------------|---------------:|
| 17  | 10.00000 | 17   | quentin   | quitter  | NA    | Engineering |           2018 |
| 21  |  6.61157 | 21   | urban     | undilat  | NA    | Marketing   |           2017 |
| 13  |  6.40000 | 13   | martin    | mustig   | NA    | Engineering |           2017 |

#### Influence Signature

Predicts, according to the article, Which employees will change others’
behavior

Measures how connected connections a person has.

Note: Implementation is vague

``` r
# Get influence measure
igraph::V(example_graph)$influence <- hrgraphsign::influence_signature(example_graph)
# Display Top 3 For Influence
knitr::kable(hrgraphsign::get_top_by_column(example_graph, column = "influence", n = 3))
```

|     | influence | name | firstName | lastName | title | department  | employmentYear | ideation |
|:----|----------:|:-----|:----------|:---------|:------|:------------|---------------:|---------:|
| 19  | 10.000000 | 19   | sara      | sommar   | NA    | Engineering |           2010 | 4.750515 |
| 13  |  7.768433 | 13   | martin    | mustig   | NA    | Engineering |           2017 | 6.400000 |
| 24  |  7.259042 | 24   | xenon     | xor      | NA    | Marketing   |           2012 | 5.874853 |

#### Comparison

``` r
set.seed(5)
layout1 <- igraph::layout.fruchterman.reingold(example_graph)
par(mfrow = c(1,2))
plot(example_graph,
     edge.width = igraph::E(example_graph)$weights,
     vertex.color = hrgraphsign::vertices_colors(example_graph, attribute = "department"),
     vertex.size = hrgraphsign::vertices_sizes(example_graph, attribute = "ideation"),
     main = "Ideation",
     layout = layout1
     )
plot(example_graph,
     edge.width = igraph::E(example_graph)$weights,
     vertex.color = hrgraphsign::vertices_colors(example_graph, attribute = "department"),
     vertex.size = hrgraphsign::vertices_sizes(example_graph, attribute = "influence"),
     main = "Influence",
     layout = layout1
)
```

![](README_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

### Efficiency signature

Predicts, according to the article, Which teams will complete projects
on time.

The efficiency signature is a combination of a team with high cohesion,
or density, and at the same time have high external range which means
having members that are well connected outside the team.

In the implementation here it is assumed that the number of vertices
connected to the team, up to three steps away, is an okey measure of
external range.

``` r
# Create subgraph for efficiency measure
team_graph <- example_graph %>%
  igraph::induced_subgraph(., igraph::V(.)[igraph::V(.)$department == "Engineering"])
# Get measure
team_efficiency <- hrgraphsign::efficiency_signature(example_graph, team_graph)
```

### Misc

#### Plot friends\_friends

``` r
par(mfrow = c(1,2))
subgraph <- hrgraphsign::friends_friends(example_graph, 13, 2)
set.seed(10)
layout2 <- igraph::layout.fruchterman.reingold(subgraph)
  plot(subgraph,
       edge.width = igraph::E(example_graph)$weights,
       vertex.color = hrgraphsign::vertices_colors(subgraph, attribute = "department"),
       vertex.size = hrgraphsign::vertices_sizes(subgraph, attribute = "ideation"),
       main = "Ideation",
       layout = layout2
  )
  plot(subgraph,
       edge.width = igraph::E(example_graph)$weights,
       vertex.color = hrgraphsign::vertices_colors(subgraph, attribute = "department"),
       vertex.size = hrgraphsign::vertices_sizes(subgraph, attribute = "influence"),
       main = "Influence",
       layout = layout2
  )
```

![](README_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->
