#' Search along a random search grid
#'
#' @param grid      random search grid
#' @param FUN       function to be applied
#' @param maximise  boolean value indicate weather parameters that maximise a function
#'                  should be selected. Defaults to FALSE
#' @importFrom pbapply pbapply
#' @export

random_search <- function(grid, FUN, maximise = FALSE, verbose = FALSE){

  grid_df <- as.data.frame(grid, check.names = FALSE)

  res <- pbapply(grid_df, 1, function(x){
                              args <- as.list(x)
                              capture.output(value <- do.call(FUN, args = args)) 
                              value
          })
  
  output <- data.frame(grid_df, .output = res)
  return(output)

}
