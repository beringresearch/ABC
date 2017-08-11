#' Random Hyperparameter Search
#'
#' @param FUN       Function to be optimised
#' @param bounds    list object specifying names and ranges of hyperparameters
#' @param niter     number of random interations
#' @param verbose   boolean value that controls verbosity
#' @export

random_search <- function(FUN,
                          bounds,
                          niter = 100,
                          verbose = TRUE){

  grid <- lapply(bounds, function(x){
                 from <- x[1]
                 to <- x[2]
                 if (class(x) == "numeric"){
                   runif(niter, from, to)
                 } else if (class(x) == "integer"){
                   sample(from:to, size=niter, replace = TRUE)
                 }
                 }
                 )
  
  grid <- data.frame(grid)

  output <- apply(grid, 1, function(x) {
                    args <- as.list(x)
                    capture.output(res <- do.call(FUN, args))
                    
                    if (verbose){ 
                      out <- args 
                      out$Score = res
                      cat(paste(names(out), out, sep=": "), "\n")
                    }

                    return(res)
                 })
  res <- grid
  res$Score <- output
  return(res)


}
