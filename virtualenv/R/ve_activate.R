#' Activate a virtual environment
#'
#' @param name 	character string
#' @export

ve_activate <- function(name){

	HOME <- Sys.getenv("HOME")
	ve_dir <- file.path(HOME, ".renvironments")
	env_dir <- file.path(ve_dir, name)
	
	message(paste0("Setting current R environment to ", name))
 	out <- eval(Sys.setenv(R_ENVIR = env_dir), globalenv())	
}
