#' Peak into contribution of any variable to a predictive model
#'
#' @param model 	Trained predictive model.
#' @param X 		data.frame which was used to train the predictive model. It should not
#' 			contain the column which is predicted by the model.
#' @param feature 	Name of the feature of interest.
#' @param which.class   Integer specifying which column of the matrix of predicted
#'			probabilities to use as the "focus" class. Default is to use
#' 			the first class. Only used for classification problems.
#' @param predict 	Custom predict function that obtaines class probabilities from model
#' @param ... 		Optional parameters to the cutsom predict function.
#' @export

qpeak <- function(model, X, feature, which.class=1L, predict, ...){

	if (! feature %in% colnames(X))
		stop(paste0(feature, " not found oin column names of the training set."))
	
	ix <- match(feature, colnames(X))	
	x_new <- X[,-ix]
	feature_vector <- X[,ix]
	
	is.factor <- sapply(x_new, class) == "factor"

	if (sum(!is.factor) > 0)
		x_new[, !is.factor] <- apply(x_new[, !is.factor], 2, replace_continuous)

	if (sum(is.factor) > 0)
		x_new[, is.factor] <- apply(x_new[, is.factor], 2, replace_factor)

	cnames <- c(colnames(X)[ix], colnames(x_new))
	x_new <- cbind(feature_vector, x_new)
	colnames(x_new) <- cnames
	
	# Remove duplicated features if predictor is a factor.
	# Only predict using unique factor levels	
	if (is.factor(ix))
		x_new <- x_new[!duplicated(x_new),]

	yh <- predict(model, x_new, ...)
	
	if (!is.numeric(yh))
		stop("predict must return numeric matrix of class probabilities.")

	odds <- yh[,which.class]/(1-yh[,which.class])

	out <- data.frame(x=x_new[,1], yhat=odds)
	colnames(out) <- c(feature, "odds")

	return(out)
}

#' Helper functions
#' Replaces continuous variables with their mediam
replace_continuous <- function(x){
	rep(median(x), length(x))
}

#' Replaces factor variables with the first
replace_factor <- function(x){
	rep(levels(as.factor(x))[1], length(x))
}
