#' Shiny interface to CytoRF clustering algorithm
#'
#' @param port      Numeric port number for shiny server. Defaults to 1234
#' @import ggplot2
#' @import Rtsne
#' @import shiny shinyFiles flowCore RColorBrewer
#' @export

cytorf.ui <- function(port = 1234){	
  shiny::runApp(system.file("shiny", package="cytorf"), port = port)
}
