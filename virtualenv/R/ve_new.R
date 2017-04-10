#' Initialize a virtual environment
#'
#' @param name			character string specifying the name of a new environment
#' @param config_path		path the yaml config file
#' @importFrom yaml yaml.load_file
#' @export

ve_new <- function(name=NULL, config_path=NULL){

	if (!is.null(name)){
		HOME <- Sys.getenv("HOME")
		ve_dir <- file.path(HOME, ".renvironments")
		env_dir <- file.path(ve_dir, name)

		# Create home directory if it doesn't exist
		if(!dir.exists(ve_dir)) dir.create(ve_dir)

		out <- ifelse(dir.exists(env_dir),
	       	stop(paste0("Environment ", name, " already exists. Run ve_remove() to delete it.")),
	       	dir.create(file.path(env_dir), showWarnings = FALSE)
	       	)	
	}
	
	# Create environment from YAML file
	if (!is.null(config_path)){
		config <- yaml.load_file(config_path)
		name <- config$name

		HOME <- Sys.getenv("HOME")
		ve_dir <- file.path(HOME, ".renvironments")
		env_dir <- file.path(ve_dir, name)

		# Create home directory if it doesn't exist
		if(!dir.exists(ve_dir)) dir.create(ve_dir)

		out <- ifelse(dir.exists(env_dir),
	       	stop(paste0("Environment ", name, " already exists. Run ve_remove() to delete it.")),
	       	dir.create(file.path(env_dir), showWarnings = FALSE)
	       	)
	
		# Interate through all listed resources
		resources <- config$resources

		for (r in 1:length(resources)){	
			if (resources[[r]]$name == "CRAN"){		
				pkgs <- names(resources[[r]]$packages)
				version <- as.vector(resources[[r]]$packages)
				if (length(pkgs) > 0){
					for (n in 1:length(pkgs)){
					install_package_version(pkgs[n], version=version[n], 
								repos=resources[[r]]$url,
								lib=env_dir)
					}
					# Install dependencies	
					deps <- unique(unlist(tools::package_dependencies(pkgs, recursive=TRUE)))
					# Remove base packages from dependency list
					deps <- setdiff(deps, installed.packages(priority="base")[,"Package"])
					if (length(deps)>0)
						install.packages(deps, lib=env_dir)
				}		
			}
		}

	}

	# Migrate base packages to the new virtualenv directory
	base <- installed.packages(priority="base")

	out <- file.copy(from=file.path(base[,"LibPath"], rownames(base)),
		  to=env_dir, recursive=TRUE)
	
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

