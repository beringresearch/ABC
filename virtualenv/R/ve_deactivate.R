#' Deactivate current virtual environment
#'
#' Upon deactivation, R environment is set to default package environemnt.
#' All attached packages are unloaded
#'
#' @export

ve_deactivate <- function(){

	session <- sessionInfo()
	loadedPkgs <- c(names(session$otherPkgs))
	
	if (!is.null(loadedPkgs)){
		loadedPkgs <- paste("package", loadedPkgs, sep=":")
		lapply(loadedPkgs, detach, unload=TRUE, character.only=TRUE)
	}

	.libPaths(Sys.getenv("R_LIBS_USER"))
	require(virtualenv)
}
