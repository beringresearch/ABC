#' Load a library through an activate R environment
#' 
#' @param package
#' @export

ve_library <- function(package){
	renvir <- Sys.getenv("R_ENVIR")
	library(package, lib.loc = renvir, character.only = TRUE)
}
