#' Deactivate current virtual environment
#'
#' Upon deactivation, R environment is set to default package environemnt.
#' All attached packages are unloaded
#'
#' @export

ve_deactivate <- function(){

	suppressMessages(
			 repeat{

				 pkgs <- setdiff(loadedNamespaces(), c("stats","graphics","grDevices", "utils", "datasets", "methods", "base"))

				 if (length(pkgs) == 0) break
				 for (pkg in pkgs) {
					 try(unloadNamespace(pkg), silent = TRUE)
				 }
			 }
			 )

	.libPaths(Sys.getenv("R_LIBS_USER"))
	require(virtualenv, quietly=TRUE)
	
}
