#' Search along a random search grid
#'
#' @param grid      random search grid
#' @param FUN       function to be applied
#' @param maximise  boolean value indicate weather parameters that maximise a function
#'                  should be selected. Defaults to FALSE
#' @importFrom pbapply pblapply
#' @export

random_search <- function(grid, FUN, maximise = FALSE){
  
  gridl <- split(grid, seq(nrow(grid)))
  res <- pblapply(gridl, function(x){
                              capture.output(value <- do.call(FUN, args = x)) 
                              value
          })
  
  output <- data.frame(grid, .output = unlist(res))
  return(output)

}
