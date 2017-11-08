#' Checkout a model and associated data files from version control
#'
#' @param  repo     character string of a model repository
#' @param  version  character string of the specific version
#' @import DBI RSQLite
#' @export

ml_checkout <- function(repo, version){
  # Get path to mlvc database
  HOME <- Sys.getenv("HOME")
  mlvc_dir <- file.path(HOME, ".mlvc") 
  
  mlvc <- dbConnect(SQLite(), file.path(mlvc_dir, paste0(repo, ".sqlite")))
  
  object <- dbReadTable(mlvc, name = repo, check.names = F) 
  raw <- object[, version]

  res <- lapply(raw, 'unserialize')

  names(res) <- c("model", "X", "Y", "comment")
  res$hash <- version
  res$version <- .unhash(version)


  class(res) <- c("mlvc", class(res)) 
  
  dbDisconnect(mlvc) 

  return(res)
}

#' @export
print.mlvc <- function(x){
  cat("MLVC object\n",
      "Version: ", x$version, "\n",
      "Comment: ", x$comment, "\n",
      "Model accessor: $model\n",
      "Data accessor: $X\n",
      "Response accessor: $Y\n")
}
