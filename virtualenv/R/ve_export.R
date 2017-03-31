#' Export R package environment
#'
#' Generate a .yaml file with full package listings and corresponding versions.
#' The file can then be used to create new virtualenv settings.
#'
#' @param name character name of the environment to be generated
#' @importFrom yaml as.yaml
#' @export

ve_export <- function(name){
	
	config <- list()
	config$name <- name
	config$R <- R.version.string
	config$CRAN <- list()

	installed_packages <- installed.packages()[,c("Package","Version")]	
	pkg <- installed_packages[,"Version"]
	names(pkg) <- installed_packages[,"Package"]	
	config$CRAN <- as.list(pkg)	

	yaml <- as.yaml(config)
	
	fileConn<-file(paste0(name, ".yaml"))
	writeLines(yaml, fileConn)
	close(fileConn)

}
