#' Upload file into local rsqlite database
#'
#' @param path 		character string
#' @param name 		character string indicating table name
#'
#' @import RSQLite DBI
#' @export

push_fcs <- function(path, name, sqlpath = "~/.deepflow/deepflow.db"){
	
	X <- data.table::fread(path)
	X <- as.data.frame(unclass(X))
	keep <- sapply(X, class) %in% c("numeric", "integer")
	X <- X[,keep]
	db <- dbConnect(SQLite(), sqlpath)
	dbWriteTable(db, name, X)
	dbDisconnect(db)



}

#' @export
pull_fcs <- function(name, sqlpath = "~/.deepflow/deepflow.db"){

	db <- dbConnect(SQLite(), sqlpath)
	X <- dbReadTable(db, name)
	dbDisconnect(db)

	return(X)

}
