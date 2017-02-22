#' Draw pretty network graphs with ggplot
#'
#' @param g 	igraph object
#' @param node	list
#' @param label list
#' @import ggplot2 ggrepel
#' @importFrom igraph layout_nicely V get.edgelist
#' @export

ggnet <- function(g, node = list(label = NA, color = "grey50", size = 1),
		     label = list(size = 1, color = "black")){
	
	if (any(!(c("label", "color", "size") %in% names(node))))
		stop("Node attribute list must contain label, color, and size fields")

	xy <- layout_nicely(g)
	edges <- get.edgelist(g, names = F)

	edges.df <- data.frame(xy[ edges[, 1], ], xy[ edges[, 2], ])
       	colnames(edges.df) <- c("X1", "Y1", "X2", "Y2")
	nodes.df <- data.frame(x = xy[,1], y = xy[,2], col = node$color, 
			       lbl = node$label, size = node$size)

	g <- 	ggplot() + 		
		geom_curve(data = edges.df, aes(x = X1, xend = X2, y = Y1, yend = Y2), curvature = -0.1, color = "grey50") +
	        geom_point(data = nodes.df, aes(x = x, y = y, col = col, size = size)) +
		geom_text_repel(data = nodes.df, aes(x = x, y = y, label = lbl, size = label$size)) +
		theme_blank()

	if(is.numeric(node$color)){
		g <- g + scale_colour_distiller(palette = "Spectral")
	}else{
		g <- g + scale_fill_brewer(palette = "Set1")
	}

	return(g)

}

#' @export
theme_blank <- function(base_size = 12, base_family = "", ...) {
	ggplot2::theme_bw(base_size = base_size, base_family = base_family) +
		ggplot2::theme(axis.text = ggplot2::element_blank(),
				axis.ticks = ggplot2::element_blank(),
				axis.title = ggplot2::element_blank(),
				legend.key = ggplot2::element_blank(),
				panel.background = ggplot2::element_rect(fill = "white", colour = NA),
				panel.border = ggplot2::element_blank(),
				panel.grid = ggplot2::element_blank(),
				...
				)
 }
