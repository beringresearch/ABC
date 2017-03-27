#' Deactivate current virtual environment
#'
#' Upon deactivation, R environment is set to default package environemnt
#'
#' @export

ve_deactivate <- function(){
	.libPaths(Sys.getenv("R_LIBS_USER"))
}
