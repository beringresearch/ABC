#' Simple interface to STRINGdb
#'
#' @param ids				character vector
#' @param score				numeric
#' @param additional_network_nodes 	numeric
#'
#' @importFrom igraph graph.data.frame add_vertices
#' @importFrom httr GET content
#' @export

stringdb <- function(ids, score=900, additional_network_nodes = 1){
	identifiers <- paste0(ids, collapse = "%0D")
	request <- paste0("http://string-db.org/api/psi-mi-tab/interactionsList?identifiers=", identifiers, "&required_score=", score, "&additional_network_nodes=", additional_network_nodes, "&species=9606")
	r <- GET(request)

	rows <- strsplit(content(r), "\n")
	t <- lapply(rows, strsplit, "\t")
	dt <- data.frame(matrix(unlist(t), nrow = length(unlist(rows)), byrow = T))

	g <- graph.data.frame(dt[,3:4], directed = F)
	
	if(sum(V(g)$name %in% ids) < length(ids)){
		nv <- length(setdiff(ids, V(g)$name)) 
		g <- add_vertices(g, nv, attr = list(name = setdiff(ids, V(g)$name)))
	}

	V(g)$searchkey <- V(g)$name %in% ids

	return(g)
}

