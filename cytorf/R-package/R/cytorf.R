#' Perform unsupervised clusering using random forest
#'
#' @param X 		      a data matrix for the flow cytometry data, it needs to have
#' 			              at least two columns.
#' @param Y 		      a factor vector of phenotypes (optional).
#' @param channels 	  a vector of two channel names or their corresponding indices.
#' 			              When it is left unspecified, all the variables will be included
#' 			              in clustering.
#' @param num.trees 	number of trees to grow in a Random Forest.
#' @param N 	        number of neighbours for calculation of affinity matrix.
#' @param sub.sample  double indicating a fraction random elements to chose for
#'                    calculation of proximity matrix. Range is 0-1.
#'                    matrix calculation
#' @param seed 		    random seed that controls clustering reproducibility
#' @param verbose 	  boolean level of verbosity (default: FALSE)
#' @useDynLib cytorf
#' @importFrom Rcpp sourceCpp
#' @importFrom igraph graph_from_adjacency_matrix cluster_louvain membership
#' @import ranger
#' @export

cytorf <- function(X, Y=NULL, channels=NULL,
		   num.trees=125, N=10, sub.sample = 0.01, seed=1234, verbose=FALSE){
	
	if (!is.null(channels))
		X <- X[,channels]

	if (ncol(X) < 2) stop("Input matrix should have at least two columns.")

	if (is.null(colnames(X))) stop("X values must contain unique column names.")
  
  if (sub.sample < 0) stop("sub.sample should be a positive number.")

  if (sub.sample <= 1) sub.sample <- round(sub.sample * nrow(X)) 

  set.seed(seed)
  ix <- sample(1:nrow(X), sub.sample, replace = FALSE)
	train <- data.frame(X[ix, ], check.names = FALSE)
	train$Y <- Y[ix, ]

	# Generate synthetic data for unsupervised prediction
	if (is.null(Y)){
		set.seed(seed)
		n_obs <- nrow(train)
		synth_X <- apply(train, 2, function(x){
				 	sample(x, n_obs, replace = TRUE)})

		train <- data.frame(rbind(train, synth_X), check.names = FALSE)
		train$Y <- as.factor(rep(c(1, 2), each = nrow(train)/2))
	}
   

	if (verbose) cat("Building Random Forest model...\n")
	# Build a random forest model and extract terminal nodes	
	set.seed(seed)
	model <- ranger(data=train, dependent.variable.name="Y", num.trees=num.trees)

  if (verbose) cat("Assigning terminal nodes...\n") 
	terminal_nodes <- predict(model, X[ix,], type="terminalNodes")$predictions

	# Compute proximity matrix
	if (verbose) cat("Calculating proximity matrix...\n")
	proximity <- proximity_matrix(terminal_nodes)
  pr <- proximity/num.trees
    
  # Compute affinity matrix
  if (verbose) cat("Calculating affinity matrix...\n")
  affinity <- make_affinity(pr, N)
    
	# Louvain clustering
	if (verbose) cat("Clustering objects...\n")	
	g <- graph_from_adjacency_matrix(affinity, mode="undirected", weighted=T, diag=F)
	cl <- cluster_louvain(g)
	groups <- as.numeric(membership(cl)) 

  df <- data.frame(X[ix,], Y = as.factor(groups), check.names = FALSE)
  model <- ranger(data = df, dependent.variable.name = "Y", num.trees = num.trees)
  clusters <- as.numeric(predict(model, X, type = "response")$predictions)
 

	res <- structure(list(labels=clusters,
			      model=model,
			      options=list(channels=channels, num.trees=num.trees,
                         N = N, sub.sample = sub.sample,
                         seed=seed)), class="cytorf")

	return(res)
}

# Helper functions
make_affinity <- function(S, n.neighbors=10) {
    N <- length(S[,1])
    if (n.neighbors >= N) {  # fully connected
        A <- S
    } else {
        A <- matrix(rep(0,N^2), ncol=N)
        for(i in 1:N) { 
            # only connect to those points with larger similarity
            best.similarities <- sort(S[i,], decreasing=TRUE)[1:n.neighbors]
            for (s in best.similarities) {
                j <- which(S[i,] == s)
                A[i,j] <- S[i,j]
                A[j,i] <- S[i,j] 
            }
        }
    }
    A  
}
