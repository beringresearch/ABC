#' Generate an affinity matrix for a single run
#'
#' @param X_train   training set
#' @param X_test    testing set
#' @param num_trees number of trees
#' @param N         number of nearest neighbours for affinity matrix
#' @param ...       additional parameters to ranger
#' @param verbose   control verbosity
#' @export

compute_affinity_matrix <- function(X_train, X_test, num_trees, N, ..., verbose = TRUE, seed = 1234){
  
  if (verbose) cat("Building Random Forest model...\n")
	# Build a random forest model and extract terminal nodes	
	set.seed(seed)	
  model <- ranger(data = X_train, dependent.variable.name = "Y",
                  num.trees = num_trees, ...)

  if (verbose) cat("Assigning terminal nodes...\n") 
	terminal_nodes <- predict(model, X_test,
                            type="terminalNodes")$predictions

  # Compute proximity matrix
	if (verbose) cat("Calculating proximity matrix...\n")
	proximity <- proximity_matrix(terminal_nodes)
  pr <- proximity/num_trees

  # Compute affinity matrix
  if (verbose) cat("Calculating affinity matrix...\n")
  affinity <- affinity_matrix(pr, N)
  
  return(affinity)
}

proximity_matrix <- function(terminal_nodes){
  proximity_matrix <- rcpp_proximity_matrix(terminal_nodes) 
}

affinity_matrix <- function(S, n.neighboors=2) {
  N <- length(S[,1])

  if (n.neighboors >= N) {  # fully connected
      A <- S
    } else {
      A <- matrix(rep(0,N^2), ncol=N)
      for(i in 1:N) { # for each line
        # only connect to those points with larger similarity 
        best.similarities <- sort(S[i,], decreasing=TRUE)[1:n.neighboors]
        for (s in best.similarities) {
          j <- which(S[i,] == s)
          A[i,j] <- S[i,j]
          A[j,i] <- S[i,j] 
         }
       }
    }
   A  
}
