#' Define command line arguments
#'
#' 
#' @import R6
#' @export

ArgumentParser <- function(){

  object <- argparse$new()
  return(object)

}

argparse <- R6Class(
  "ArgumentParser",
  portable = TRUE,
  lock_objects = FALSE,
  
  public = list(
    initialize = function(){
      self$args <- vector()
      self$type <- vector()
      self$help <- vector()
    },
    
    add_argument = function(name, type, help=""){

      if( !(type %in% c("numeric", "charager", "logical")))
        stop("type must be one of 'numeric', 'character', or 'logical'")
      
      self$args <- c(self$args, name)
      self$type <- c(self$type, type)
      self$help <- c(self$help, help)
    
    },

    parse_args = function(args){ 
      
      args <- strsplit(args, "=")

      kv <- lapply(args, function(x){
        ix <- match(x[1], self$args)
        type <- self$type[ix]
        switch(type,
          numeric = {value <- as.numeric(x[2])},
          character = {value <- as.character(x[2])},
          logical = {value <- as.logical(x[2])}
        )
        res <- list(x=value)
        names(res) <- x[1]
        return(res)
      })
      
      kv <- data.frame(kv, check.names = FALSE)
      colnames(kv) <- gsub("--", "", colnames(kv))
      kv 
    }
  ) 

)
