#' Activate a virtual environment
#'
#' @param name 	character string
#' @export

ve_activate <- function(name){

	HOME <- Sys.getenv("HOME")
	ve_dir <- file.path(HOME, ".renvironments")
	env_dir <- file.path(ve_dir, name)
		
	if (file.exists(env_dir)){	
		message(paste0("Switching current R environment to ", name))	
 		out <- eval(Sys.setenv(R_ENVIR=env_dir), globalenv())
		assign(".lib.loc", env_dir, envir = environment(.libPaths))
	}else{
		stop(paste0("Environment", name, " does not exist. Run ve_new(", name, ") to create it."))
	}	
}
