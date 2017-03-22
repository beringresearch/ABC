#' Initialize a virtual environment
#'
#' @param name			character name of the new environment
#' @param dependancies		path the yaml config file
#' @export

ve_new <- function(name, dependencies){

	HOME <- Sys.getenv("HOME")
	ve_dir <- file.path(HOME, ".renvironments")
	env_dir <- file.path(ve_dir, name)

	# Create home directory if it doesn't exist
	if(!dir.exists(ve_dir)) dir.create(ve_dir)

	out <- ifelse(dir.exists(env_dir),
	       stop(paste0("Environment ", name, " already exists. Run ve_delete to delete it.")),
	       dir.create(file.path(env_dir), showWarnings = FALSE)
	       )

	# Copy dependencies yaml to environment directory for future use
	out <- file.copy(from=dependencies, to=env_dir)
	
	# Generate a list of dependencies from yaml
	deps <- yaml.load_file(dependencies)
	
	# Cycle through repositories, installing specific packages
	repositories <- names(deps$Repository)

	for (n in repositories){
		if (n=="CRAN"){
			task <- deps$Repository[[n]]$Packages
			pkg <- names(task)
			version <- as.vector(unlist(task))
		       	url <- get_package_url(pkg, version)	
			install.packages(url, repos=NULL, type="source", lib=env_dir)
		}
	}

}

get_package_url <- function(pkg, version){
	packageurl <- paste0("http://cran.r-project.org/src/contrib/Archive/",
			     pkg,"/", pkg,"_", version, ".tar.gz")
	return(packageurl)
}
