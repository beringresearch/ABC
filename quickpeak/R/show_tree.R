#' Visual representation of a single tree from a random forest model
#'
#' @param model     random forest model as produced by ranger package
#' @param tree      integer reflecting which tree to visualise
#' @import ranger ggraph igraph ggplot2
#' @export

show_tree <- function(model, tree){

  trees <- lapply(1:model$num.trees, function(x) treeInfo(model, x))

  # Generate adjacency matrix
  tree <- trees[[tree]]
  adjm <- matrix(0, nc = nrow(tree), nr = nrow(tree))

  for (n in 1:nrow(tree)){
    ix <- as.numeric(tree[n, c(2, 3)] + 1)
    adjm[n, ix]  <- 1
  }

  jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF",
                                   "cyan", "#7FFF7F", "yellow",
                                   "#FF7F00", "red", "#7F0000"))

  g <- graph_from_adjacency_matrix(adjm, mode = "directed")
  V(g)$color <- rev(jet.colors(vcount(g)))

  leafnodes <- sapply(V(g), function(x) length(neighbors(g, x))==0 )
  size <- sapply(1:vcount(g), function(x){
                   length(unique(unlist(shortest_paths(g, from = x, to = which(leafnodes))$vpath)))-1
})
  V(g)$size <- size + 1

  graph <- ggraph(g, "kk") +
    geom_edge_diagonal() +
    geom_node_point(aes(colour = size, size = size)) +
    scale_colour_gradientn(colours = jet.colors(vcount(g))) +
    theme_void() +
    theme(legend.position="none")
  
  return(graph)

} 
