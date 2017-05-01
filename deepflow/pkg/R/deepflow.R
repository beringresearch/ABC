#' DeepFlow structure detection algorithm
#'
#' @param x 		numerical matrix
#' @param transform	boolean value indicating whether arcsinh/5 transformation
#'			should take place
#' @param gui 		boolean value indicating whether a shiny application should be launched
#' @param seed		random seed to ensure reproducibility
#' @importFrom rmarkdown run
#' @import largeVis kerasR
#' @export

deepflow <- function(x=NULL, transform=FALSE, gui=TRUE, seed=1234){

	if (gui){
		app <- system.file("rmd", "deepflow.Rmd", package = "deepflow")
		file.copy(app, getwd())
		run("deepflow.Rmd", dir = getwd())
		unlink("deepflow.Rmd")
		return()
	}

	if (transform)
		x <- asinh(x/5)

	a <- autoencoder(x)
	yh <- as.data.frame(keras_predict(a$encoder, scale(x)))

	set.seed(seed)
	v <- largeVis(t(yh), threads=parallel::detectCores(), verbose=TRUE, seed=seed)
	xy <- t(v$coords)
	return(xy)

}
