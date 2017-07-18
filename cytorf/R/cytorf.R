#' Perform unsupervised clusering using random forest
#'
#' @useDynLib cytorf
#' @importFrom Rcpp sourceCpp
#' @importFrom igraph graph_from_adjacency_matrix cluster_louvain membership
#' @import ranger
#' @export

cytorf <- function(X, num.trees=50, scale=5, seed=1234){

	# Generate synthetic data
	set.seed(seed)
	n_obs <- nrow(X)
	synth_X <- apply(X, 2, function(x){
				 sample(x, n_obs)})

	train <- as.data.frame(rbind(X, synth_X))
	train$Y <- as.factor(c(rep(1, nrow(X)), rep(2, nrow(synth_X))))
	
	set.seed(seed)
	model <- ranger(data=train, dependent.variable.name="Y", num.trees=num.trees)
	terminal_nodes <- predict(model, X, type="terminalNodes")$predictions
	proximity <- proximity_matrix(terminal_nodes)

	pr <- proximity/(2*num.trees)
	g <- graph_from_adjacency_matrix(pr^scale, mode="undirected", weighted=T, diag=F)
	cl <- cluster_louvain(g)
	groups <- membership(cl)
	return(groups)
}
