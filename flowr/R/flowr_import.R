#' Elegant import of a library
#' 
#' Try to import dependency, if missing, install it
#' Currently support CRAN and BioConductor repositories.
#' 
#' @param package 	character string
#' @export

flowr_import <- function(package){
		
	available <- require(package, character.only = TRUE,
			  quietly = TRUE,
			  warn.conflicts = FALSE)	
	if(!available){
		if(package %in% available.packages()[, 1]){
			install.packages(package)
		} else{
			source("https://bioconductor.org/biocLite.R")
			biocLite(package)
		}		
	}

}
