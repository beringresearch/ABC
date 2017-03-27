#'  Automated Microarray Profiler
#'
#' @param setup		path to the .yaml file outlining project set up
#' @import tufte oligo limma
#' @importFrom rmarkdown render
#' @export

maprofiler <- function(setup){

	# Read project specifications
	exec_options <- yaml::yaml.load_file(setup)
	
	# Load required libraries
	require(exec_options$array$annotation_lib, character.only=TRUE)

	# Generate Header
	title <- exec_options$title
	author <- exec_options$author
	email <- exec_options$email
	datapath <- exec_options$datapath
	pdatapath <- exec_options$pdatapath
	outdir <- exec_options$outdir

	celFiles <- oligoClasses::list.celfiles(datapath, full.names=TRUE)
	raw <- oligo::read.celfiles(celFiles)
	data <- oligo::rma(raw, target="core")

	# Annotate array with sample and gene descriptions	
	phenotype <- read.csv(pdatapath, stringsAsFactors=FALSE)
	ix <- match(colnames(raw), phenotype[,1])
	phenotype <- phenotype[ix, ]
	phenoData(data) <- AnnotatedDataFrame(data=phenotype)
	colnames(data) <- colnames(raw)

	gene_symbol <- paste0(exec_options$array$annotation_obj,"SYMBOL")
	gene_name <- paste0(exec_options$array$annotation_obj, "GENENAME")
	gene_ensembl <- paste0(exec_options$array$annotation_obj, "ENSEMBL")
	gene_entrez <- paste0(exec_options$array$annotation_obj, "ENTREZID")

	annotation <- data.frame(SYMBOL=sapply(contents(get(gene_symbol)), paste, collapse=","),
				 NAME=sapply(contents(get(gene_name)), paste, collapse=","),
				 ENSEMBLID=sapply(contents(get(gene_ensembl)), paste, collapse=","),
				 ENTREZID=sapply(contents(get(gene_entrez)), paste, collapse=","))

	ix <- match(featureNames(data), rownames(annotation))
	featureData(data) <- AnnotatedDataFrame(data=annotation[ix,])
	mask <- featureData(data)$ENTREZID == "NA"
	eset <- data[!mask,]
	
	saveRDS(eset, file.path(outdir, "processedEset.rds"))

	# Principal Component Analysis
	pc <- prcomp(exprs(eset), scale = TRUE)
	variance <- cumsum((pc$sdev)^2 / sum(pc$sdev^2))
	
	# Differential Expression Analysis
	comparisons <- exec_options$comparisons
	description <- pData(eset)$Description
	modelMatrix <- model.matrix(~0+description)
	colnames(modelMatrix) <- unique(description)
	# Generate a fitted model
	fit <- lmFit(eset, modelMatrix)
	# Create contrasts
	contrastMatrix <- makeContrasts(contrasts = comparisons, levels = modelMatrix)
	fit2 <- contrasts.fit(fit, contrastMatrix)
	fit2 <- eBayes(fit2)
	top.genes <- topTable(fit2, coef = 1, number = Inf, adjust = "BH", p.value = 0.05)
	all.genes <- topTable(fit2, coef = 1, number = Inf, adjust = "BH")

	# Write files to outdir
	write.table(top.genes, file.path(outdir, "differentially_expressed_genes.txt"), quote = F, row.names = F, sep = "\t")
	saveRDS(top.genes, file.path(outdir, "differentially_expressed_genes.rds"))
	saveRDS(all.genes, file.path(outdir, "differential_expression_all_genes.rds"))

	
	render(system.file("rmd/maprofiler.Rmd", package="bering.abc"),
	       output_format="tufte_handout",
	       output_dir = getwd())

}
