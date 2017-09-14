#' Search along a random search grid
#'
#' @param grid      random search grid
#' @param FUN       function to be applied
#' @param maximise  boolean value indicate weather parameters that maximise a function
#'                  should be selected
#' @export

search <- function(grid, FUN, maximise = FALSE){

  grid_df <- as.data.frame(grid, check.names = FALSE)

 capture.output( res <- apply(grid_df, 1, function(x){
                              args <- as.list(x)
                              do.call(FUN, args = args)
          })
  )
  
  output <- data.frame(grid_df, .output = res)
  return(output)

}
