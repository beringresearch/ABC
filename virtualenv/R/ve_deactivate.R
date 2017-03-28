#' Deactivate current virtual environment
#'
#' Upon deactivation, R environment is set to default package environemnt
#'
#' @export

ve_deactivate <- function(){

	session <- sessionInfo()
	loadedPkgs <- names(session$otherPkgs)
	pkg <- paste("package:", loadedPkgs, sep="")
	lapply(pkg, detach, character.only = TRUE, unload = TRUE)

	.libPaths(Sys.getenv("R_LIBS_USER"))
}
