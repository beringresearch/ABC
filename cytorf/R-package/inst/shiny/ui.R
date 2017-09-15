library(shiny)
library(shinyFiles)

shinyUI(
	fluidPage(
				titlePanel("CytoRF"),

				 sidebarLayout(position="left",

				 sidebarPanel(width = 3,   
					      numericInput("ntrees", "Number of Trees",
							   125, min = 2, max = 1000),
					      numericInput("nearest_neighbour", "Nearest Neighbours",
							   10, min=1, max=250),
                numericInput("sub_sample", "Subsampling",
                 1000, min = 100, max = Inf),
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
								    htmlOutput("run_analysis_run")),
								div(style="display: inline-block;vertical-align:top; width: 200px;",
								    helpText("Running time is directly proportional to number of events from each file. To quickly assess clustering output, select a small subsample.")),

								hr()
								),
						    
                tabPanel("Results",
								h4("Gate explorer"),
								helpText("Click on individual points or select a gate from the dropdown below to further explore clusters."),
                br(), 
                htmlOutput("select_gate"),
                
								div(style="display: inline-block;vertical-align:top; width: 500px;", 
  							plotOutput("plot_cluster", click = "plot_click")),
								div(style="display: inline-block;vertical-align:top; width: 500px;",
								plotOutput("plot_density")),
                
                br(), 
                br(),
                div(style="display: inline-block;vertical-align:top; width: 300px;",
                htmlOutput("export_selected_gate_fcs")), 
                div(style="display: inline-block;vertical-align:top; width: 200px;",
                htmlOutput("export_all_gates_fcs")),

                br(),
								hr(),
								h4("Channel expression levels"),
								div(style="display: inline-block;vertical-align:top; width: 500px;",
								    plotOutput("plot_expression")),
								div(style="display: inline-block;vertical-align:top; width: 500px;",
								    htmlOutput("visualise_channel")),

								hr(),
                h4("Predictive Gate Importances"),
                helpText("In cases where sample descriptions are supplied, CytoRF will automatically identify cellular populations that predict outcome of interest."),
                plotOutput("gate_predictions")
								),

						       tabPanel("Help"))

					  )
				 )
				 )
)
