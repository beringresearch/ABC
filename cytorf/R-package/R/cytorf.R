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
                   num.trees=125, N=10,
                   sub.sample = 0.01,
                   seed=1234,
                   verbose=FALSE){
  
  if (!is.null(channels))
    X <- X[,channels]

	if (ncol(X) < 2)
    stop("Input matrix should have at least two columns.")

	if (is.null(colnames(X)))
    stop("X values must contain unique column names.")
  
  # Subsampling error handling 
  if (sub.sample < 0)
    stop("sub.sample should be a positive number.")
  if (sub.sample <= 1 & is.null(Y))
    sub.sample <- round(sub.sample * nrow(X))
  if (sub.sample > nrow(X))
    stop("Trying to subsample on more events than there are rows in X.")

  
	# Generate synthetic data for unsupervised prediction
	if (is.null(Y)){
    set.seed(seed)
    # Sub sample in class-independent fashion
    subsampling_index <- sample(1:nrow(X), sub.sample, replace = FALSE)
    train <- data.frame(X[subsampling_index, ], check.names = FALSE)
    train$Y <- Y[subsampling_index, ]

    # Generate a synthetic dataset
    n_obs <- nrow(train)
    synth_X <- apply(train, 2, function(x)
                     {
                       sample(x, n_obs, replace = TRUE)
                     }
    )
    train <- data.frame(rbind(train, synth_X), check.names = FALSE)
    train$Y <- as.factor(rep(c(1, 2), each = nrow(train)/2))

  } else{

    # Check that length of Y matches to number of rows in X
    if (length(Y) != nrow(X))
      stop("Length of Y does not equal to number of rows in X.")

    if (!is.factor(Y))
      Y <- factor(Y, levels = unique(Y))

    if (sub.sample <= 1){
      freq_table <- round(table(Y) * sub.sample)
    }else {
      freq_table <- rep(sub.sample, length(levels(Y)))
    }

    subsampling_index <- vector()
    for (n in 1:length(freq_table)){
      class_index <- which(Y == levels(Y)[n])
      ix <- sample(class_index, freq_table[n])
      subsampling_index <- c(subsampling_index, ix)
    }

    train <- data.frame(X[subsampling_index, ], check.names = FALSE)
    train$Y <- Y[subsampling_index]
  }

	if (verbose) cat("Building Random Forest model...\n")
	# Build a random forest model and extract terminal nodes	
	set.seed(seed)
	model <- ranger(data=train, dependent.variable.name="Y", num.trees=num.trees)

  if (verbose) cat("Assigning terminal nodes...\n") 
	terminal_nodes <- predict(model, X[subsampling_index, ],
                            type="terminalNodes")$predictions

	# Compute proximity matrix
	if (verbose) cat("Calculating proximity matrix...\n")
	proximity <- proximity_matrix(terminal_nodes)
  pr <- proximity/num.trees
    
  # Compute affinity matrix
  if (verbose) cat("Calculating affinity matrix...\n")
  affinity <- affinity_matrix(pr, N)
    
	# Louvain clustering
	if (verbose) cat("Clustering objects...\n")	
	g <- graph_from_adjacency_matrix(affinity, mode="undirected", weighted=T, diag=F)
	cl <- cluster_louvain(g)
	groups <- as.numeric(membership(cl)) 

  df <- data.frame(X[subsampling_index,], Y = as.factor(groups), check.names = FALSE)
  model <- ranger(data = df, dependent.variable.name = "Y", num.trees = num.trees)
  clusters <- as.numeric(predict(model, X, type = "response")$predictions)
 

	res <- structure(list(labels=clusters,
			      model=model,
			      options=list(channels=channels, num.trees=num.trees,
                         N = N, sub.sample = sub.sample,
                         seed=seed)), class="cytorf")

	return(res)
}

#' Extract proximity matrix
#'
#' @param terminal_nodes  vector
#' @export
proximity_matrix <- function(terminal_nodes){
  rcpp_proximity_matrix(terminal_nodes)
}


#' Extract affinity matrix from proximity matrix
#' 
#' @param S   square matrix
#' @param N   nearest neighbours
#'
#' @export
affinity_matrix <- function(S, N=10) {
    n <- length(S[,1])
    if (N >= n) {  # fully connected
        A <- S
    } else {
        A <- matrix(rep(0,n^2), ncol=n)
        for(i in 1:n) { 
            # only connect to those points with larger similarity
            best.similarities <- sort(S[i,], decreasing=TRUE)[1:N]
            for (s in best.similarities) {
                j <- which(S[i,] == s)
                A[i,j] <- S[i,j]
                A[j,i] <- S[i,j] 
            }
        }
    }
    A  
}
