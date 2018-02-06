#' Cytovis
#'
#' @import largeVis igraph
#' @export

cytovis <- function(X, ...){
  
  lv <- largeVis(t(X), ...)
  affinity <- lv$wij
  
  g <- graph_from_adjacency_matrix(affinity, mode="undirected",
                                   weighted = TRUE, diag = FALSE) 
	cl <- cluster_louvain(g)
	clusters <- as.numeric(membership(cl))

	res <- structure(list(labels = clusters, lv = lv), 
                   class="cytorf")
  return(res)
}
