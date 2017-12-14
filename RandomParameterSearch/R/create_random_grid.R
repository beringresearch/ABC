#' Create a Random Search Space
#'
#' @param nrounds   number of random iterations
#' @param params    a list of parameters with low and high values
#' @param seed      random seed
#' @export

create_random_grid <- function(nrounds = 100, params, seed = 1234){

  space <- lapply(params, function(x){
                    if (length(x) > 1){
                      if (class(x) == "integer"){
                        res <- sample(min(x):max(x), nrounds, replace = TRUE)
                      } else{
                        res <- runif(n = nrounds, min = min(x), max = max(x)) 
                      }
                    }else{
                      res <- rep(x, nrounds)
                    }
                    return(res)
                })

  return(space)

}
