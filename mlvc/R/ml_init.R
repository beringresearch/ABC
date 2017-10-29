#' Initialize ML Version Control repository
#'
#' @import RSQLite DBI
#' @export

ml_init <- function(){
  HOME <- Sys.getenv("HOME")
  mlvc_dir <- file.path(HOME, ".mlvc") 
  
  original_directory <- getwd()

  # Create home directory if it doesn't exist
  if(!dir.exists(mlvc_dir)) dir.create(mlvc_dir)

  # Initialize the SQLite database if it doesn't exist
  setwd(mlvc_dir)
  exists <- "mlvc.sqlite" %in% dir()

  if (!exists){  
    cat("Initializing new database...")
    mlvc <- dbConnect(RSQLite::SQLite(), "mlvc.sqlite")
    dbDisconnect(mlvc)
    cat("Done\n")
  }

  setwd(original_directory)

}
