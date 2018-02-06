#' @export

get_proximity_matrix <- function(terminal_nodes){

	proximity <- rcpp_proximity_matrix(terminal_nodes)  

  return(proximity)
}

#' @export
get_terminal_nodes <- function(X_train, X_test, ..., num_trees, verbose, seed){
  set.seed(seed)	
  model <- ranger(data = X_train, dependent.variable.name = "Y",
                  num.trees = num_trees, ...)

  if (verbose) cat("Assigning terminal nodes...\n") 
	terminal_nodes <- predict(model, X_test,
                            type="terminalNodes")$predictions
}

#' import RANN
#' @export
get_affinity_matrix_nn <- function(S, k=2) {
  
  r <- nrow(S)
  A <- matrix(rep(0, r^2), ncol = r)

  nn <- nn2(S, S, k = k, searchtype = "standard")

  for (i in 1:r){
    w <- seq(1, 0, length.out = k)
    A[i, nn$nn.idx[i ,]] <- 1
    A[nn$nn.idx[i, ], i] <- 1 
  }
  
  A
}
