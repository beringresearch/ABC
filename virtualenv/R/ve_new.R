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
	
	# Install CRAN repositories
	cran <- match("CRAN", names(config))

	if(!is.na(cran)){
		pkgs <- names(config[[cran]])
		version <- as.vector(unlist(config[[cran]]))
		
		for (n in 1:length(pkgs)){
			install_package_version(pkgs[n], version=version[n], lib=env_dir)
		}

		# Install dependencies	
		deps <- unique(unlist(tools::package_dependencies(pkgs, recursive=TRUE)))
		# Remove base packages from dependency list
		deps <- setdiff(deps, installed.packages(priority="base")[,"Package"])
		install.packages(deps, lib=env_dir)			
	}else{
		stop("virtualenv does not support repositories other than CRAN for the time being.")
	}
}

# Install a specific version of the package.
install_package_version <- function(pkg, version, repos = getOption("repos"), type = getOption("pkgType"),
			...){
	contriburl <- contrib.url(repos, type)
	available <- available.packages(contriburl)

	if (pkg %in% row.names(available)) {
		current.version <- available[pkg, 'Version']
		if (is.null(version) || version == current.version) {
			return(install.packages(pkg, repos = repos, ...))
	        }else{
			url <- get_package_url(pkg, version)
			install.packages(url, repos=NULL, type="source", ...)

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

