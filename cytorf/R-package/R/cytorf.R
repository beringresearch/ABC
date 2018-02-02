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
#' @param subsample   double indicating a fraction of random observations to
#'                    chose for calculation of proximity matrix. Range is 0-1.
#'                    This parameter can be used to speed up model construction#'                    by sampling at random a small partition of the dataset.
#' @param seed 		    random seed that controls clustering reproducibility
#' @param verbose 	  boolean level of verbosity (default: FALSE)
#' @param ...         additional parameters to be passed to ranger function
#' @useDynLib cytorf
#' @importFrom Rcpp sourceCpp
#' @importFrom igraph graph_from_adjacency_matrix cluster_louvain membership
#' @import ranger
#' @export

cytorf <- function(X, Y=NULL, channels=NULL,                 
                   num_trees = 150,
                   N=5,
                   subsample = 0.25, 
                   seed=1234,
                   verbose=FALSE, ...){
  
  if (!is.null(channels))
    X <- X[,channels]

	if (ncol(X) < 2)
    stop("Input matrix should have at least two columns.")

	if (is.null(colnames(X)))
    stop("X values must contain unique column names.")
  
  # Subsampling processing and error handling 
  if (subsample < 0)
    stop("subsample should be a positive number.")
  if (subsample <= 1) 
    subsample <- floor(subsample * nrow(X))
  if (subsample > nrow(X))
    stop("Trying to subsample on more events than there are rows in X.")

  
	# Generate synthetic data for unsupervised prediction
  set.seed(seed) 
  subsampling_index <- sample(1:nrow(X), subsample, replace = FALSE)

  train <- data.frame(X[subsampling_index, ], check.names = FALSE)
  train$Y <- Y[subsampling_index, ]

  # Generate a synthetic dataset
  n_obs <- nrow(train) 
  synth_X <- apply(train, 2, function(x) runif(n_obs, min = min(x), max = max(x)))

  train <- data.frame(rbind(train, synth_X), check.names = FALSE)
  train$Y <- as.factor(rep(c(1, 2), each = nrow(train)/2))

  
  # Generate affinity matrix
  affinity <- compute_affinity_matrix(train,
                                      X[subsampling_index, ],
                                      num_trees, N, #...,
                                      verbose = verbose, seed = seed)
 
  affinity <- exp(affinity) 
  
	# Louvain clustering
	if (verbose) cat("Clustering objects...\n")	
	g <- graph_from_adjacency_matrix(affinity, mode="undirected",
                                   weighted=T, diag=F)
	cl <- cluster_louvain(g)
	groups <- as.numeric(membership(cl)) 

  # Extrapolate smaller model to full dataset
  df <- data.frame(train[, 1:ncol(X)],
                   Y = as.factor(groups), check.names = FALSE)
   
  model <- ranger(data = df, dependent.variable.name = "Y",
                  num.trees = num_trees, ...)
  
  clusters <- as.numeric(predict(model, X, type = "response")$predictions)
 
	res <- structure(list(labels = clusters, 
			                  model = model),
                   class="cytorf")

	return(res)
}
