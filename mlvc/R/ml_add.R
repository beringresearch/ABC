#' Add a model and training data to database
#'
#' @param model     model object
#' @param X         data.frame containing training data
#' @param Y         vector containing response data
#' @param title     character title of the model-data environment
#' @param comment   a brief description associated with the commit
#' @import RSQLite DBI
#' @export

ml_add <- function(model, X, Y, title, comment = ""){
  
  # Get path to mlvc database
  HOME <- Sys.getenv("HOME")
  mlvc_dir <- file.path(HOME, ".mlvc") 
   
  mlvc <- dbConnect(SQLite(), file.path(mlvc_dir, "mlvc.sqlite"))
  
  # Attempt to serialize the model
  cat("Storing model and data files...")
  object <- data.frame(x = I(lapply(list(model = model, X = X, Y = Y, comment = comment),
                                         function(x) serialize(x, NULL))))
  object$id <- rownames(object)
  colnames(object) <- c(.hash(), "id")
  
  # Check if the table exists
  tables <- dbListTables(mlvc)
  exists <- title %in% tables
  
  if(!exists){
    dbWriteTable(conn=mlvc, name=title, value=object)
  }else{ 
      # Insert a new empty column
      query <- paste0("ALTER TABLE ", title, " ADD COLUMN '", colnames(object)[1], "' TEXT")
      out <- capture.output(suppressWarnings(dbGetQuery(mlvc, query)))

      # Populate new column with data
      query <- paste0("UPDATE ", title, " SET '",
                      colnames(object)[1], "' = :",
                      colnames(object)[1], " where id = :id")
      out <- capture.output(suppressWarnings(dbExecute(mlvc, query, object)))
  }
  
  cat("Done\n")
  dbDisconnect(mlvc)
}

.hash <- function(n = 5){
  paste(charToRaw(as.character(Sys.time())), collapse = "")
}
