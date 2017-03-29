#' List R environments
#'
#' @export

ve_list <- function(){

	HOME <- Sys.getenv("HOME")
	ve_dir <- file.path(HOME, ".renvironments")

	# Create home directory if it doesn't exist
	if(!dir.exists(ve_dir)) dir.create(ve_dir)

	envs <- dir(ve_dir, full.names = FALSE)

	if (length(envs) > 0){
		res <- data.frame(Active=NA,Environment=NA, Size=NA, Owner=NA, Libraries=NA)

		for(n in 1:length(envs)){
			info <- file.info(file.path(ve_dir, envs[n]))
			res[n, "Environment"] <- envs[n]
			res[n, "Size"] <- info$size	
			res[n, "Owner"] <- info$uname
			res[n, "Libraries"] <- length(environment_libs(envs[n]))
		}
		res[,"Active"] <- ""
		active_env <- unlist(strsplit(.libPaths(), paste0(ve_dir, "/")))[2]
		ix <- match(active_env, res[,"Environment"])
		if (!is.na(ix))
			res[ix, "Active"] <- "*"
			
		return(res)	
	}else{
		message("No R environments. Run ve_new() to create one.")
	}
}

#' Show environment libraries
environment_libs <- function(name){
	HOME <- Sys.getenv("HOME")
	ve_dir <- file.path(HOME, ".renvironments", name)
	setdiff(dir(ve_dir, full.names = FALSE), "environment.yaml")
}
