#' Initiliase deepflow application
#'
#' @param dbname 	database name to be used across the application
#' @param dbpath 	path pointing to location of SQLite database on disk
#' @export
#' @import RSQLite

deepflow_init <- function(dbname, dbpath){

	db <- file.path(dbpath, dbname)

	con <- dbConnect(SQLite(), dbname=db)
	dbDisconnect(con)
	
	Sys.setenv(DEEP_DB=db)

}
