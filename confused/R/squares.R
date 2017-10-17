#' Squares
#'
#' @param predicted   a vector of predicted class probabilities
#' @param reference   a vector (factor) of classes to be used as the tru results
#' @import ggplot2
#' @export

squares <- function(predicted, reference){

  bering.colours <- c("#B1CDE1", "#4E77B1", "#BFDE8E", "#639F3A", "#E49998", "#C12022",
                      "#EDBD73", "#E47E1D", "#C3B1D4", "#603F96")
                      
  classes <- levels(reference)
  
  df <- data.frame(predicted, Reference = reference)
  
  for (n in 1:length(classes)){
    df[df$Reference != classes[n],
       which(colnames(df) == classes[n])] <- NA
  }

  df <- reshape2::melt(df, id.vars = "Reference")

  

  ggplot(df, aes(value, fill = Reference)) +
    geom_histogram(bins = 25) +
    coord_flip() +
    facet_wrap(~Reference, nrow = 1) + theme_bw() +
    scale_fill_manual(values=bering.colours[1:length(classes)]) +
    theme_classic() +
    theme(axis.line.x = element_line(color="white"),
          axis.ticks.x = element_blank(),
          axis.text.x = element_text(colour="white"),
          strip.background = element_blank(),
          legend.position = "none") +
    ylab("") + xlab("Prediction Score")
    
}
