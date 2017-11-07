.onLoad <- function(lib, pkg) {
  HOME <- Sys.getenv("HOME")
  mlvc_dir <- file.path(HOME, ".mlvc")
   
  if(!dir.exists(mlvc_dir)) dir.create(mlvc_dir)
}
