#' Shiny interface to CytoRF clustering algorithm
#'
#' @import ggplot2
#' @import largeVis
#' @import shiny shinyFiles
#' @export

cytorf.ui <- function(){	

	app <- list(
		    ui=fluidPage(
				 titlePanel("CytoRF"),
				 sidebarPanel( 
					      verbatimTextOutput("path"),
					      shinyDirButton("path",
							     label="Change Project Folder",
							     title="Select Project Folder"),
					      br(),br(),
					      h3("Clustering Options"), 
					      numericInput("ntrees", "Number of Trees",
							   125, min = 2, max = 1000),
					      numericInput("scale", "Cluster Granularity",
							   7, min=1, max=25),
					      numericInput("seed", "Random Seed",
							   12345, min=1, max=Inf)
					      ),

				 mainPanel(
					   tabsetPanel(type = "tabs",
						       tabPanel("Files",
								verbatimTextOutput("fcs")),
						       tabPanel("Run Analysis"),
						       tabPanel("Results"),
						       tabPanel("Help"))

					  )
				 ),
		    server=function(input, output){	
		    		 
			    	shinyDirChoose(input, 'path',
					   roots=c(home=Sys.getenv("HOME")), 
					   filetypes=c('fcs'))
			    
			    	path <- reactive({do.call('file.path',
					as.list(c(Sys.getenv("HOME"), unlist(input$path$path))))})
			    	output$path <- renderText(path())
			    	output$fcs <- renderText(paste0(list.files(path(), pattern=".fcs", ignore.case = TRUE), "\n"))
		
		    }
		    )
	runApp(app)

}
