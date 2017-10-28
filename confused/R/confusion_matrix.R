#' Confusion Matrix
#'
#' Graphical visualisation of a confusion matrix
#'
#' @param predicted   a factor of predicted class labels.
#' @param reference   a factor of classes to be used as the true results.
#' @export
#' @import ggplot2

confusion_matrix <- function(predicted, reference){

  cm <- .table(predicted, reference)

  cm <- as.data.frame(cm)
  colnames(cm) <- c("predicted", "reference", "Freq")
  cm$reference <- factor(as.character(cm$reference), levels = rev(levels(cm$reference)))
  
  g <- ggplot(cm, aes(x = predicted, y = reference, fill = Freq)) +
       geom_raster() +
       xlab("Reference Class") + ylab("Predicted Class") +
       theme_minimal() + 
       theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  
  panel_height = unit(1,"npc") - sum(ggplotGrob(g)[["heights"]][-3]) - unit(1,"line") 

  g <- g + scale_fill_gradient(name = "Counts",
                            breaks = seq(0, max(cm$Freq, 1)),
                            low = "white", high = "darkblue",
                            guide =  guide_colourbar(barheight = panel_height))

  g

}

.table <- function(x,y) {
  x <- factor(x)
  y <- factor(y)
  commonLevels <- sort(unique(c(levels(x), levels(y))))
  x <- factor(x, levels = commonLevels)
  y <- factor(y, levels = commonLevels)
  table(x,y)
}
