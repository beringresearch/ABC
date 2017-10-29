#' Delete model version control history
#'
#' @param title   character string of a model repository
#' @param version character string of the specific model version to be deleted. Not implemented
#' @import DBI RSQLite
#' @export

ml_delete <- function(title, version){
  # Get path to mlvc database
  HOME <- Sys.getenv("HOME")
  mlvc_dir <- file.path(HOME, ".mlvc") 
  
  mlvc <- dbConnect(SQLite(), file.path(mlvc_dir, "mlvc.sqlite"))

  dbRemoveTable(mlvc, title)
  
  dbDisconnect(mlvc) 

}
