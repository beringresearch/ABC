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
	
	installed_packages <- installed.packages()[,c("Package","Version")]	
	pkg_version <- installed_packages[,"Version"]
	pkg_name <- installed_packages[,"Package"]
	pkg_source <- sapply(pkg_name, pkg_contriburl)

	resource_names <- unlist(lapply(unique(pkg_source), function(x) x[1]))
	resource_names <- resource_names[!is.null(resource_names)]
	resource_url <- unlist(lapply(unique(pkg_source), function(x) x[2]))
	resource_url <- resource_url[!is.null(resource_url)]
	
	resources <- vector("list", length(resource_names))
	for (n in 1:length(resources)){
		resources[[n]]$name <- resource_names[n]
		resources[[n]]$url <- resource_url[n]
		pkg <- names(which
			     (unlist(lapply(pkg_source,
					    function(x) x[1] == resource_names[n]))))
		pkg_list <- list()
		pkg_list <- pkg_version[match(pkg, pkg_name)]
		names(pkg_list) <- pkg
		resources[[n]]$packages <- as.list(pkg_list)
	}	

	config$resources <- resources

	yaml <- as.yaml(config)
	
	fileConn<-file(paste0(name, ".yaml"))
	writeLines(yaml, fileConn)
	close(fileConn)
}

# Check to see if a package is available through CRAN or something else.
pkg_contriburl <- function(pkg_name){
	contriburl <- contrib.url("https://cran.r-project.org/", "both")
	cran <- available.packages(contriburl)	
	bioc <- available.packages(repos="https://bioconductor.org/packages/release/bioc/")
	repo=NULL
	if (pkg_name %in% rownames(cran)) repo <- c("CRAN", "https://cran.r-project.org/")
	if (pkg_name %in% rownames(bioc)) repo <- c("Bioconductor", "https://bioconductor.org/packages/release/bioc/")
	return(repo)
}
