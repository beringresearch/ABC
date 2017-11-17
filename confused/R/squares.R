#' Squares
#'
#' @param predicted   a matrix of predicted class probabilities
#' @param reference   a vector (factor) of classes to be used as the true result
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
  
  if (length(classes) > 20)
    stop("This functions doesn't support > 20 classes at this time.")
  if (ncol(predicted) != length(classes))
    stop("Number of columns in predicted class probabilities does not match total number of classes.")
  if (any(!(colnames(predicted) %in% classes)))
    stop("Predicted class probability column names must match reference class levels")
   
  label <- colnames(predicted)[apply(predicted, 1, which.max)]
  df <- data.frame(predicted, Reference = reference, Label = label,
                   check.names = FALSE)

  df$Reference <- factor(df$Reference, levels = sort(classes))
  df$Label <- factor(df$Label, levels = sort(classes))

  
  for (n in 1:length(classes)){
    df[df$Reference != classes[n],
       which(colnames(df) == classes[n])] <- NA
  }

  m <- reshape2::melt(df, id.vars = c("Reference", "Label"))
  m <- na.omit(m)

  g <- ggplot(m, aes(x = value, y = ..ndensity..)) +
        geom_histogram(aes(fill = Label), bins = bins) +
        geom_hline(aes(yintercept = 0, colour = Reference, group = Reference)) +  
        coord_flip() + 
        scale_fill_manual(values = bering.colours[1:length(classes)],
                          limits = levels(m$Reference)) +
        scale_colour_manual(values = bering.colours[1:length(classes)],
                            limits = levels(m$Reference)) +
        facet_wrap(~ Reference) +
        theme_classic() +
        theme(axis.line.x = element_line(colour = "white"),
              axis.line.y = element_line(colour = "white"),
              axis.ticks.x = element_blank(),
              axis.ticks.y = element_blank(),
              axis.text.x = element_text(colour = "white"),
              strip.background = element_blank(),
              legend.position = "none") + 
        ylab("") + xlab("Prediction Score")
   
  return(g)  
}
