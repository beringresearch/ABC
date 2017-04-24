#' Draw a labeled volcano plot
#'
#' @param fc 	numeric vector
#' @param pval 	numeric vector
#' @param lbl	character vector
#' @param ntop	numeric number of top labels to show
#' @import ggplot2 ggrepel ggthemes
#' @export

volcanoplot <- function(fc, pval, lbl = NULL, ntop = length(lbl)){
	if (!is.null(lbl) & (length(lbl) != length(fc) | length(lbl)!= length(pval)))
		stop("Label length must match fc and pval vector length.")
	
	l <- rep(NA, length(lbl))
	pos_ix <- order(fc, decreasing=TRUE)
	neg_ix <- order(fc, decreasing=FALSE)
	l[pos_ix[1:ntop]] <- lbl[pos_ix[1:ntop]]
	l[neg_ix[1:ntop]] <- lbl[neg_ix[1:ntop]]

	df <- data.frame(fc = fc, pval = pval, col = as.factor(ifelse(fc > 0, "up", "down")), lbl = l)

	g <- ggplot(df, aes(x = fc, y = -log10(pval), col = col)) +
		geom_point() +
		geom_text_repel(aes(label = lbl), show.legend = FALSE) +
		xlab("Fold Change") +
		ylab("-log(p-value)") +
		scale_colour_manual(values = c("#047c2c","#d5004a"),
				    labels = c("Down-regulated", "Up-regulated"),
				    name = "") +
		theme_minimal()

	return(g)
}
