#' Draw a labeled volcano plot
#'
#' @param fc 	numeric vector
#' @param pval 	numeric vector
#' @param lbl	character vector
#' @import ggplot2 ggrepel ggthemes
#' @export

volcanoplot <- function(fc, pval, lbl = NULL){

	if (!is.null(lbl) & (length(lbl) != length(fc) | length(lbl)!= length(pval)))
		stop("Label length must match fc and pval vector length.")

	df <- data.frame(fc = fc, pval = pval, col = as.factor(ifelse(fc > 0, "up", "down")), lbl = lbl)

	g <- ggplot(df, aes(x = fc, y = -log10(pval), col = col)) +
		geom_point() +
		geom_text_repel(aes(label = lbl), show.legend = FALSE) +
		xlab("Fold Change") +
		ylab("-log(p-value)") +
		scale_colour_manual(values = c("#047c2c","#d5004a"),
				    labels = c("Up-regulated", "Down-regulated"),
				    name = "") +
		theme_minimal()

	return(g)
}
