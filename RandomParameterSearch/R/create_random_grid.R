#' Create a Random Search Space
#'
#' @param nrounds   number of random samples from continuous hyperparameters
#' @param params    a list of parameters with low and high values
#' @param seed      random seed
#' @export

create_random_grid <- function(nrounds = 100, params, seed = 1234){

  space <- lapply(params, function(x){
                    if (length(x) > 1){
                      if (class(x) == "integer"){
                        res <- sample(min(x):max(x), nrounds, replace = TRUE)
                      } else if(typeof(x) == "double"){
                        res <- runif(n = nrounds, min = min(x), max = max(x)) 
                      } else if(typeof(x) == "character"){
                        res <- x
                      } 
                    }else{
                      res <- x 
                    }
                    return(res)
                })

  res <- expand.grid(space, stringsAsFactors = FALSE)

  return(res)

}
