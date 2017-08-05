#' Shiny interface to CytoRF clustering algorithm
#'
#' @param port      Numeric port number for shiny server. Defaults to 1234
#' @import ggplot2
#' @import Rtsne
#' @import shiny shinyFiles flowCore RColorBrewer
#' @export

cytorf.ui <- function(port = 1234){	

	global = reactiveValues(
        file_names = NULL,
        fcs_raw = NULL,
				X = NULL,
        Y = NULL,
				g = NULL,
				coords = NULL)

	app <- list(	
		    ui=fluidPage(
				 titlePanel("CytoRF"),

				 sidebarLayout(position="left",

				 sidebarPanel(width = 3,   
					      numericInput("ntrees", "Number of Trees",
							   125, min = 2, max = 1000),
					      numericInput("scale", "Cluster Granularity",
							   7, min=1, max=25),
					      numericInput("seed", "Random Seed",
							   12345, min=1, max=Inf)
					      ),

				 mainPanel(width = 9,
					   tabsetPanel(type = "tabs",
						       tabPanel("Setup Your Analysis",
								br(),
								h4("Step 1: Chose Project Files"),
								div(style="display: inline-block;vertical-align:top; width: 700px;",

								shinyFilesButton("files",
							     		label="Chose Project Files",
							     		title="Select Project Files",	
							     		multiple=TRUE),

                br(),
                br(),
                htmlOutput("file_list")
								),

                					      			
								div(style="display: inline-block;vertical-align:top; width: 200px;",
								helpText("Click on the button to navigate to a folder that contains your FCS files. Select one or more files to begin your analysis.")
								),
                
                hr(),
                h4("Step 1a (Optional): Assign Samples into Groups"),
                div(style="display: inline-block;vertical-align:top; width: 700px;",
                  tags$table(class="sampleGroupTable",
                             tagList(
                             tags$tr(uiOutput("sampleGroupNameList")) 
                             ))),
                div(style="display: inline-block;vertical-align:top; width: 200px;",
								    helpText("Optionally, assign each file from Step 1 into a group to improve results of automated cluster detection.")),

								hr(),
								h4("Step 2: Select Channels of Interest"),	
								div(style="display: inline-block;vertical-align:top; width: 700px;",
								    htmlOutput("channel_list")
								),
								div(style="display: inline-block;vertical-align:top; width: 200px;",
								    helpText("Select two or more items from the Available Channels list. Selected channels will be used to cluster your FCS data and overlay it with relevant expression profiles.")
								),
                
                hr(),
								h4("Step 3: Cluster"),
								div(style="display: inline-block;vertical-align:top; width: 700px;",
								    htmlOutput("run_analysis_subsample"),
								    htmlOutput("run_analysis_run")),
								div(style="display: inline-block;vertical-align:top; width: 200px;",
								    helpText("Running time is directly proportional to number of events from each file. To quickly assess clustering output, select a small subsample.")),

								hr()
								),
						       tabPanel("Results",
								h4("Gate explorer"),
								helpText("Click on individual points or select a gate from the dropdown below to further explore clusters."),
                
                htmlOutput("select_gate"),

								div(style="display: inline-block;vertical-align:top; width: 500px;",
                
  							plotOutput("plot_cluster", click = "plot_click")),
								div(style="display: inline-block;vertical-align:top; width: 500px;",
								plotOutput("plot_density")
								),

								hr(),
								h4("Channel expression levels"),
								div(style="display: inline-block;vertical-align:top; width: 500px;",
								    plotOutput("plot_expression")),
								div(style="display: inline-block;vertical-align:top; width: 500px;",
								    htmlOutput("visualise_channel")),

								hr(),
								h4("Mean channel expressions"),
								helpText("Mean marker expression is calculated by aggregating channel values across all CytoRF gates."),
								plotOutput("plot_heatmap")	
								),

						       tabPanel("Help"))

					  )
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
             global$file_names <- fcs_file$name

				     output$file_list <- renderUI({
               return(tagList(
                 lapply(as.list(global$file_names),
                   function(x){
                     tags$tr(
                       tags$td(x)
                     )
                   })
               ))
             })

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
							  
							  # Show Channel List in Results section
							  output$visualise_channel <- renderUI({
								  selectInput("visualise_channel",
									      "Visualise Channel",
									      choices = input$channel_list,
									      multiple = FALSE)})
					})
				})
    
    # Sample Group Assigment
    output$sampleGroupNameList = renderUI({
      return(tagList(
                     lapply(as.list(global$file_names),
                            function(x) {
                              tags$tr(
                                tags$td(
                                  textInput(inputId=paste0(x, "_group"), label=x)
                                )
                              )
                            }
                           )
                     )
            )
    })

		# Run Analysis
		observeEvent(input$run, {
             
             group.input.id <- names(input)[which(regexpr(text=names(input), pattern="_group")>0)]
             group <- unlist(lapply(group.input.id, function(x) input[[x]]))   

				     fcs <- fsApply(global$fcs_raw, function(x, cofactor=5){
							    set.seed(input$seed)
							    nevents <- input$nevents
							    if (nevents > nrow(x)) nevents <- nrow(x)
							    subsample <- sample(1:nrow(x),
										nevents, replace=FALSE)

							    colnames(x) <- global$fcs_raw@colnames
							    
							    expr <- exprs(x)
							    expr <- asinh(expr[subsample,] / cofactor)
							    expr <- expr[, input$channel_list] 

							    exprs(x) <- expr
							    x})

				     global$X <- fsApply(fcs, exprs)
             if(!any(sapply(group, function(x) x ==""))){
               global$Y <- as.factor(rep(group, unlist(fsApply(fcs, nrow))))
             }

             duplicates <- duplicated(global$X)
             global$X <- global$X[!duplicates,]
             global$Y <- global$Y[!duplicates]

 				     global$g <- cytorf(X = global$X,
                                Y = global$Y,
                                num.trees = input$ntrees,
						                    scale = input$scale, seed=input$seed)$labels
				     nclusters <- length(unique(global$g))
				     echo <- paste0("Number of clusters: ", nclusters, "\n",
						    "Number of events: ", nrow(global$X))

				     output$analysis_summary <- renderText({echo})
				     
				     if (ncol(global$X) == 2){
					     	global$coords <- global$X
				     } else {
					     	tsne <- Rtsne(global$X)
					     	global$coords <- tsne$Y[,1:2]
					     	colnames(global$coords) <- c("viSNE.1", "viSNE.2")
				     }
				     
		
		# Render Clustering Plot
		output$plot_cluster <- renderPlot({
			getPalette = colorRampPalette(brewer.pal(9, "Set1"))
			colorCount <- length(unique(global$g))
	
			df <- data.frame(global$coords)
			df$Gates <- as.factor(global$g)
			ggplot(df, aes(x=df[,1], y=df[,2], color=Gates)) + geom_point() +
			xlab(colnames(global$coords)[1]) +
			ylab(colnames(global$coords)[2]) +
			scale_color_manual(values = getPalette(colorCount)) +
			theme(legend.position="none") + theme_minimal() + 
      ggtitle("CytoRF Gates")
		})

    # Render Select Gate
    output$select_gate <- renderUI({
      selectInput("select_gate",
									"Visualise Gates",
									choices = global$g,
									multiple = FALSE)
    })

    observeEvent(input$select_gate, {
      selection <- as.numeric(input$select_gate)
      ix <- global$g == selection

      output$plot_density <- renderPlot({
        g <- ggplot()
        if(is.null(global$Y)){
          df <- reshape2::melt(global$X[ix,])
          g <- g + geom_boxplot(data = df, aes(x=Var2, y=value), outlier.size = 0.1)
        } else{
          df <- data.frame(global$X, Group=global$Y)
          df <- df[ix,]
          df <- reshape2::melt(df, id.vars="Group")
          g <- g + geom_boxplot(data=df, aes(x=variable, y=value, fill=Group),
                                outlier.size = 0.1)
        }
        g <- g + xlab("") + ylab("Channel expression level") + coord_flip() +
						 theme_minimal() + ggtitle(paste0("Gate: ", selection))	
        g
        }
        )
    })

		# Render Channel Density plot
    observeEvent(input$plot_click, {
		  output$plot_density <- renderPlot({	
			  ix <- input$plot_click	
			
			  np <- data.frame(nearPoints(as.data.frame(global$coords),
				   input$plot_click,
				   xvar = colnames(global$coords)[1],
				   yvar = colnames(global$coords)[2],
				   threshold = 10, maxpoints = 1,
				   addDist = FALSE))	
			  ix <- as.numeric(rownames(np))	
			
			  gate <- global$g[ix]
			  ix <- global$g == gate 
      
			  g <- ggplot()
        if(is.null(global$Y)){
          df <- reshape2::melt(global$X[ix,])
          g <- g + geom_boxplot(data = df, aes(x=Var2, y=value), outlier.size = 0.1)
        } else{
          df <- data.frame(global$X, Group=global$Y)
          df <- df[ix,]
          df <- reshape2::melt(df, id.vars="Group")
          head(df)
          g <- g + geom_boxplot(data=df, aes(x=variable, y=value, fill=Group), outlier.size = 0.1)
        }
        g <- g + xlab("") + ylab("Channel expression level") + coord_flip() +
						  theme_minimal()	+ ggtitle(paste0("Gate: ", gate))
        g
		  })
    }
    )
		
		# Render Expression Plot
		output$plot_expression <- renderPlot({
			selected_gate_value <- global$X[,input$visualise_channel]
			
			jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan",
							 "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))

	
			df <- data.frame(global$coords)	
			ggplot(df, aes(x=df[,1], y=df[,2], color=selected_gate_value)) + geom_point() +
			xlab(colnames(global$coords)[1]) +
			ylab(colnames(global$coords)[2]) +
			scale_colour_gradientn(colours = jet.colors(7), name="Expression") +
			theme_minimal()	
		}, width=575)

		# Render Cluster Explorer
		output$cluster_explorer <- renderPlot({
			getPalette = colorRampPalette(brewer.pal(9, "Set1"))
			colorCount <- length(unique(global$g))
	
			df <- data.frame(global$coords)
			df$Gates <- as.factor(global$g)
			ggplot(df, aes(x=df[,1], y=df[,2], color=Gates)) + geom_point() +
			xlab(colnames(global$coords)[1]) +
			ylab(colnames(global$coords)[2]) +
			scale_color_manual(values = getPalette(colorCount)) +
			theme(legend.position="none") + theme_minimal()
			
		})
		
		# Render Cluster Information text
		output$cluster_info <- renderPrint({
	
			np <- data.frame(nearPoints(as.data.frame(global$coords),
				   input$plot_click,
				   xvar = colnames(global$coords)[1],
				   yvar = colnames(global$coords)[2],
				   threshold = 10, maxpoints = 1,
				   addDist = FALSE))

			if (nrow(np)==0){
				data.frame(np)
			}else{
				cluster <- global$g[as.numeric(rownames(np))]
				members <- sum(global$g == cluster)
				data.frame(np, Cluster=cluster, Members=members)
			}
		})

		# Render marker heatmap
		output$plot_heatmap <- renderPlot({
			jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan",
							 "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))

			summ <- aggregate(global$X, by=list(global$g), FUN=mean)
			hc <- hclust(dist(t(summ[,-1])))
			data <- summ[,-1]
			data <- data[,hc$order]
			data$Gate <- as.factor(summ$Group.1)
			df <- reshape2::melt(data, id.vars="Gate",)
			ggplot(df, aes(x=Gate, y=variable, fill=value)) +
				geom_tile() +
				scale_fill_gradientn(colours = jet.colors(7), name="") +
				ylab("") + theme_minimal()
		}, height=600)
	
	})	

	# Close Server Function		
	}

# Close APP	
)
	runApp(app, port=port)

}
