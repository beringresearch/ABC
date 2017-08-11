/usr/local/bin/Rscript -e "library(cytorf); port <- sample(1000:9999, 1); url <- paste0('open http://localhost:', port); system(url); cytorf.ui(port);"

