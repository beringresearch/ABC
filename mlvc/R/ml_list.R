#' List the content of ML Version Control repository
#'
#' @import RSQLite DBI
#' @export

ml_list <- function(){
   
  # Get path to mlvc database
  HOME <- Sys.getenv("HOME")
  mlvc_dir <- file.path(HOME, ".mlvc")

  repo <- tools::file_path_sans_ext(list.files(path = mlvc_dir, pattern = "\\.sqlite$"))

  res <- sapply(repo, FUN = function(x){
    mlvc <- dbConnect(SQLite(), file.path(mlvc_dir, paste0(x, ".sqlite")))

    tables <- dbListTables(mlvc) 
    fields <- lapply(tables, function(x) dbListFields(mlvc, x))
    names(fields) <- tables

    # Remove id column
    fields <- lapply(fields, function(x) x[-grep("id", x)])
  
    # Unhash column names
    meta <- lapply(fields, function(x) sapply(x, .unhash))
 
    dbDisconnect(mlvc) 

    return(meta)
    }
  )

  names(res) <- repo

  return(res)
}

.unhash <- function(x){ 
  s <- substring(x, seq(1, nchar(x), 2), seq(2, nchar(x), 2))
  l <- as.raw(as.integer(paste0('0x', s)))
  rawToChar(l)
}
