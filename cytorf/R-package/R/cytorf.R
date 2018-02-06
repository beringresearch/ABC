#' Perform unsupervised clusering using random forest
#'
#' @param X 		      a data matrix for the flow cytometry data, it needs to have
#' 			              at least two columns.
#' @param channels 	  a vector of two channel names or their corresponding indices.
#' 			              When it is left unspecified, all the variables will be
#'                    included in clustering.
#' @param num_trees   number of trees
#'
#' @param N 	        number of neighbours for calculation of affinity matrix.
#' @param seed 		    random seed that controls clustering reproducibility
#' @param verbose 	  boolean level of verbosity (default: FALSE)
#' @param ...         additional parameters to be passed to ranger function
#' @useDynLib cytorf
#' @importFrom Rcpp sourceCpp
#' @importFrom igraph graph_from_adjacency_matrix cluster_louvain membership
#' @import ranger RANN
#' @export

cytorf <- function(X, channels = NULL,                 
                   num_trees = 2000,
                   delta = 0.1,
                   seed = 1234,
                   verbose = FALSE, ...){
  
  if (!is.null(channels))
    X <- X[,channels]

	if (ncol(X) < 2)
    stop("Input matrix should have at least two columns.")

	if (is.null(colnames(X)))
    stop("X values must contain unique column names.")
  
  train <- X 

  # Generate a synthetic dataset
  n_obs <- nrow(train) 
  synth_X <- apply(train, 2, function(x) runif(n_obs, min = min(x), max = max(x)))

  train <- data.frame(rbind(train, synth_X), check.names = FALSE)
  train$Y <- as.factor(rep(c(1, 2), each = nrow(train)/2))

  
  # Generate affinity matrix
  terminal_nodes <- get_terminal_nodes(train, X, 
                                       #...,
                                       num_trees = num_trees,
                                       verbose = verbose,
                                       seed = seed) 
 
  proximity_matrix <- get_proximity_matrix(terminal_nodes)
  proximity_matrix <- proximity_matrix/num_trees

  #affinity <- get_affinity_matrix_nn(proximity_matrix, k = k)

  affinity <- exp(-((1-proximity_matrix)^2)/(2 * delta^2))


  lv <- largeVis::largeVis(t(X))
  affinity <- lv$wij


  # Louvain clustering
	if (verbose) cat("Clustering objects...\n")
  g <- graph_from_adjacency_matrix(affinity, mode="undirected",
                                   weighted = TRUE, diag = FALSE) 
	cl <- cluster_louvain(g)
	clusters <- as.numeric(membership(cl))
 
 
	res <- structure(list(labels = clusters), 
                   class="cytorf")

	return(res)
}
