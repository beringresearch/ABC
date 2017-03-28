#' Initialize a virtual environment
#'
#' @param config_path		path the yaml config file
#' @export

ve_new <- function(config_path){
	
	config <- yaml::yaml.load_file(config_path)
	name <- config$name

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
	out <- file.copy(from=config_path, to=env_dir)
	
	# Cycle through repositories, installing specific packages
	repositories <- names(config$Repository)

	for (n in repositories){
		if (n=="CRAN"){

			task <- config$Repository[[n]]$Packages
			pkg <- names(task)
			version <- as.vector(unlist(task))
		       	url <- get_package_url(pkg, version)
			install.packages(url, repos=NULL, type="source", lib=env_dir)
			
			deps <- unique(unlist(sapply(file.path(env_dir, pkg), get_package_deps)))
			install.packages(deps, lib=env_dir)			
		}
	}

}

get_package_url <- function(pkg, version){
	packageurl <- paste0("http://cran.r-project.org/src/contrib/Archive/",
			     pkg,"/", pkg,"_", version, ".tar.gz")
	return(packageurl)
}

get_package_deps <- function(path) {
	dcf <- read.dcf(file.path(path, "DESCRIPTION"))
	jj <- intersect(c("Depends", "Imports"), colnames(dcf))
        val <- unlist(strsplit(dcf[, jj], ","), use.names=FALSE)
        val <- gsub("\\s.*", "", trimws(val))
	val[val != "R"]
}

