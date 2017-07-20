#' Shiny interface to CytoRF clustering algorithm
#'
#' @import ggplot2
#' @import largeVis
#' @import shiny shinyFiles flowCore
#' @export

cytorf.ui <- function(){	

	global = reactiveValues(fcs_raw = NULL)

	app <- list(	
		    ui=fluidPage(
				 titlePanel("CytoRF"),

				 sidebarPanel(  
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
						       tabPanel("Setup Clustering Analysis",
								br(),
								h3("Step 1: Chose Project Files"),
								shinyFilesButton("files",
							     		label="Chose Project Files",
							     		title="Select Project Files",	
							     		multiple=TRUE),
					      			
								hr(),
								h3("Step 2: Select Channels of Interest"),
								div(style="display: inline-block;vertical-align:top; width: 250px;",
								    htmlOutput("file_list")
								),
								div(style="display: inline-block;vertical-align:top; width: 250px;",
								    htmlOutput("channel_list")
								),
								div(style="display: inline-block;vertical-align:top; width: 250px;",
								    htmlOutput("selected_channels")
								),
								hr(),
								h3("Step 3: Cluster"),
								htmlOutput("run_analysis_subsample"),
								htmlOutput("run_analysis_run"),

								hr()
								),
						       tabPanel("Results",
								verbatimTextOutput("analysis_summary")
								),
						       tabPanel("Help"))

					  )
				 ),

	server=function(input, output){
		# File Selection
		shinyFileChoose(input, 'files',
				roots=c(home=Sys.getenv("HOME")), 
				filetypes=c('fcs'))
			    	    	
		observeEvent(input$files, {
				     fcs_file <- parseFilePaths(roots=c(home=Sys.getenv("HOME")),
								     input$files)
				     
				     global$fcs_raw <- read.flowSet(as.character(fcs_file$datapath),
							     transformation = FALSE,
							     truncate_max_range = FALSE)

				     channels <- global$fcs_raw@colnames

				     output$file_list <- renderUI({
					     selectInput("file_list",
							 "Project Files",
							 choices = fcs_file$name,
							 size = 15,
							 selected = NULL,
							 multiple = TRUE,
							 selectize = FALSE)})

				     output$channel_list <- renderUI({
					     selectInput("channel_list",
							 "Available Channels",
							 choices = channels,
							 size = 15, 
							 selected = NULL,
							 multiple = TRUE,
							 selectize = FALSE)})



				     observeEvent(input$channel_list, {
							  output$run_analysis_subsample <- renderUI({
								  numericInput("nevents",
									       "Number of events from each file",
									       1000, min=10, max=Inf)})
							  output$run_analysis_run <- renderUI({
								  actionButton("run", "Run Clustering")})
					     })
				})

		# Run Analysis
		observeEvent(input$run, {
				     fcs <- fsApply(global$fcs_raw, function(x, cofactor=5){
							    set.seed(input$seed)
							    subsample <- sample(1:nrow(x),
									   input$nevents, replace=FALSE)
							    colnames(x) <- global$fcs_raw@colnames
							    
							    expr <- exprs(x)
							    expr <- asinh(expr[subsample,] / cofactor)
							    expr <- expr[,input$channel_list] 

							    exprs(x) <- expr
							    x})

				     X <- fsApply(fcs, exprs)
				     g <- cytorf(X, num.trees=input$ntrees,
						 scale=input$scale,
						 seed=input$seed)
				     nclusters <- length(unique(g))
				     echo <- paste0("Total number of clusters: ", nclusters, "\n")

				     output$analysis_summary <- renderText({echo})

		})		
	}	
)
	runApp(app)

}
