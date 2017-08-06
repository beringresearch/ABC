/usr/local/bin/Rscript -e "library(cytorf); port <- sample(1:10000, 1); url <- paste0('open http://localhost:', port); system(url); cytorf.ui(port);"

