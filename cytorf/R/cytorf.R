#' Perform unsupervised clusering using random forest
#'
#' @param X 		a data matrix for the flow cytometry data, it needs to have
#' 			at least two columns.
#' @param Y 		a factor vector of phenotypes (optional).
#' @param channels 	a vector of two channel names or their corresponding indices.
#' 			When it is left unspecified, all the variables will be included
#' 			in clustering.
#' @param num.trees 	number of trees to grow in a Random Forest.
#' @param scale 	cluster granularity parameter. Lower and higher values result in
#' 			smaller or larger number of clusters respectively.
#' @param seed 		random seed that controls clustering reproducibility
#' @param verbose 	boolean level of verbosity (default: FALSE)
#' @useDynLib cytorf
#' @importFrom Rcpp sourceCpp
#' @importFrom igraph graph_from_adjacency_matrix cluster_louvain membership
#' @import ranger
#' @export

cytorf <- function(X, Y=NULL, channels=NULL,
		   num.trees=50, scale=5, seed=1234, verbose=FALSE){
	
	if (!is.null(channels))
		X <- X[,channels]

	if (ncol(X) < 2) stop("Input matrix should have at least two columns.")

	train <- data.frame(X)
	train$Y <- Y

	# Generate synthetic data for unsupervised prediction
	if (is.null(Y)){
		set.seed(seed)
		n_obs <- nrow(X)
		synth_X <- apply(X, 2, function(x){
				 	sample(x, n_obs)})

		train <- as.data.frame(rbind(X, synth_X))
		train$Y <- as.factor(c(rep(1, nrow(X)), rep(2, nrow(synth_X))))
	}else{
		X <- train
	}
	
	if (verbose) cat("Building Random Forest model...\n")
	# Build a random forest model and extract terminal nodes	
	set.seed(seed)
	model <- ranger(data=train, dependent.variable.name="Y", num.trees=num.trees)
	terminal_nodes <- predict(model, X, type="terminalNodes")$predictions

	# Compute proximity matrix
	if (verbose) cat("Calculating proximity matrix...\n")
	proximity <- proximity_matrix(terminal_nodes)

	# Louvain clustering
	if (verbose) cat("Clustering objects...\n")
	pr <- proximity/(2*num.trees)
	g <- graph_from_adjacency_matrix(pr^scale, mode="undirected", weighted=T, diag=F)
	cl <- cluster_louvain(g)
	groups <- as.numeric(membership(cl))

	return(groups)
}
