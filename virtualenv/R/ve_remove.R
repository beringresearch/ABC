#' Delete an R environment
#' 
#' @param names	character vector name of the environment to be deleted.
#' @export

ve_remove <- function(names) {

	HOME <- Sys.getenv("HOME")
	ve_dir <- file.path(HOME, ".renvironments")

	for (n in names){
		env_dir <- file.path(ve_dir, n)

		out <- ifelse(dir.exists(env_dir), unlink(env_dir, recursive = TRUE),
	       	stop(paste0("Nothing to delete.")))
	}	

}

