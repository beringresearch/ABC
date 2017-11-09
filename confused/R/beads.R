#' Bead Plot
#'
#' @param predicted   a matrix of predicted class probabilities
#' @param reference   a vector (factor) of classes to be used as the true result
#' @import ggplot2
#' @export

beads <- function(predicted, reference){
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

  df$Reference <- factor(df$Reference, levels = rev(classes))
  df$Label <- factor(df$Label, levels = rev(classes))


  for (n in 1:length(classes)){
    df[df$Reference != classes[n],
       which(colnames(df) == classes[n])] <- NA
  }

  m <- reshape2::melt(df, id.vars = c("Reference", "Label"))
  m <- na.omit(m)


  g <- ggplot(m, aes(x = value, y = Reference, col = Label)) +
       geom_point(position="jitter") +
       scale_colour_manual(values = bering.colours[1:length(classes)]) +
       ylab("") +  xlab("Prediction Score") +
       theme_classic() +
       scale_x_reverse() +
       theme(axis.text.y = element_text(face="bold", color = bering.colours[1:length(classes)]),
             panel.grid.major.y = element_line(colour = "grey", linetype = 2),
             legend.position = "none")

  return(g)

}
