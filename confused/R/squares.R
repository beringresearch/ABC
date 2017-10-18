#' Squares
#'
#' @param predicted   a vector of predicted class probabilities
#' @param reference   a vector (factor) of classes to be used as the tru results
#' @param bins        integer indicating number of bins to be used for histograms
#' @import ggplot2
#' @export

squares <- function(predicted, reference, bins = 10){

  bering.colours <- c("#B1CDE1", "#4E77B1", "#BFDE8E", "#639F3A", "#E49998", "#C12022",
                      "#EDBD73", "#E47E1D", "#C3B1D4", "#603F96",
                      "#56B4E9", "#D55E00", "#999999", "#009E73", "#F0E442", "#0072B2",
                      "#E69F00", "#CC79A7",
                      "#00d5c9", "#d5c900")
                      
  classes <- levels(reference)
  
  df <- data.frame(predicted, Reference = reference, check.names = FALSE)
  
  for (n in 1:length(classes)){
    df[df$Reference != classes[n],
       which(colnames(df) == classes[n])] <- NA
  }

  df <- reshape2::melt(df, id.vars = "Reference")

  g <- ggplot(df, aes(x=value, fill = Reference)) +
        geom_histogram(aes(y=..density..), bins = bins, na.rm=TRUE) +
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
   
  return(g)  
}
