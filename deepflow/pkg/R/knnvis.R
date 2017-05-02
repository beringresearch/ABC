library(RANN)
library(igraph)
library(flowCore)

fcs <- flowCore::exprs(read.FCS("~/Documents/Bering/Projects/AtheroBCell/Oxford/CYTOF/Levine/benchmark-data-Levine-32-dim/data/Levine_32dim_notransform.fcs", transformation=FALSE, truncate_max_range=FALSE))


k<-10
n <- nn2(data.matrix(iris[,1:4]))
neighbors <- n[[1]][,-1]


child <- matrix(t(neighbors), (k-1) * nrow(iris), 1, byrow=TRUE)
parent <- rep(1:nrow(iris), each=k-1)
el <- cbind(parent, child)

g <- graph_from_edgelist(el, directed=FALSE)

xy <- layout_with_lgl(g)

plot(xy, col=iris[,"Species"], pch=19)
