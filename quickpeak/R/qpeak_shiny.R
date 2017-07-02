#' Shiny interface to quickpeak
#' @param model 	Trained predictive model.
#' @param X 		data.frame which was used to train the predictive model. It should not
#' 			contain the column which is predicted by the model.
#' @param FUN 		Custom predict function that obtaines class probabilities from model
#' @param ...		Optional parameters to the
#' @import shiny ggplot2
#' @export

qpeak_shiny <- function(model, X, FUN,...){

	yh <- FUN(model, X, ...)
	classes <- unique(colnames(yh))

	app <- list(
		    ui=navbarPage(
				 theme = shinythemes::shinytheme("flatly"),
				 title = "quickpeak", 
				 tabPanel("Explorer",
				 	titlePanel("Feature Explorer"),
				 	sidebarLayout(
					       sidebarPanel(
							    selectInput("feature", "Select Feature:", 
							    choices=colnames(X)),
							    hr(),

							    selectInput("class", "Target Class:",
									choices=classes),
							    hr()
					       ),
				 		mainPanel(
							   plotOutput("featurePlot")  
						)
					)
					)
				),
		    server=function(input, output){
			    output$featurePlot <- renderPlot({
				    feature <- input$feature
				    class <- input$class 

				    q <- qpeak(model, X, feature=feature,
					       which.class=class, FUN=FUN,...)
				    df <- data.frame(Value=q[,1], Odds=q[,2])
				    ggplot(df, aes(x=Value, y=Odds)) + geom_point() +
					    ggtitle(paste0("Effect of ", feature, " on ", class)) +
					    xlab("Feature Value")
			    })
			    
		    }
		    )

	shiny::runApp(app)
}
