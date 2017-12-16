#' Create a Random Search Space
#'
#' @param nrounds   number of random samples 
#' @param params    a list of parameters with low and high values
#' @param seed      random seed
#' @export

create_random_grid <- function(nrounds = 100, params, seed = 1234){
  
  set.seed(seed)

  space <- lapply(params, function(x){
                    if (length(x) > 1){
                      if (class(x) == "integer"){
                        res <- sample(min(x):max(x), nrounds, replace = TRUE)
                      } else if(typeof(x) == "double"){
                        res <- runif(n = nrounds, min = min(x), max = max(x)) 
                      } else if(typeof(x) == "character"){
                        ix <- sample(x = 1:length(x), size = nrounds, replace = TRUE) 
                        res <- x[ix] 
                      } 
                    }else{
                      res <- rep(x, nrounds)             
                    }
                    return(res)
                })

  #res <- expand.grid(space, stringsAsFactors = FALSE)
  res <- data.frame(space, stringsAsFactors = FALSE)
  return(res)

}
