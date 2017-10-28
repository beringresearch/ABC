#' Confusion Matrix
#'
#' Graphical visualisation of a confusion matrix
#'
#' @param predicted   a factor of predicted class labels.
#' @param reference   a factor of classes to be used as the true results.
#' @export
#' @import ggplot2

confusion_matrix <- function(predicted, reference){

  cm <- table(predicted, reference)
  cm <- as.data.frame(cm)
  
  g <- ggplot(cm, aes(x = reference, y = predicted, fill = Freq)) +
        geom_raster() +
        scale_fill_gradient(name = "Frequency",
                            breaks = seq(0, max(cm$Freq, 1)),
                            low = "white", high = "darkblue") +
        xlab("Reference Class") + ylab("Predicted Class") +
        theme_minimal() +
        theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  g

}
