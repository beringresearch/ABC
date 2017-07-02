#' Peak into contribution of any variable to a predictive model
#'
#' @param model 	Trained predictive model.
#' @param X 		data.frame which was used to train the predictive model. It should not
#' 			contain the column which is predicted by the model.
#' @param feature 	Name of the feature of interest.
#' @param which.class   Integer specifying which column of the matrix of predicted
#'			probabilities to use as the "focus" class. Default is to use
#' 			the first class. Only used for classification problems.
#' @param FUN	 	Custom predict function that obtaines class probabilities from model
#' @param ... 		Optional parameters to the custom predict function.
#' @export

qpeak <- function(model, X, feature=NULL, which.class=1L, FUN=predict, ...){
	
	if (is.null(feature)) qpeak_shiny(model, X, FUN,...)

	if (! feature %in% colnames(X))
		stop(paste0(feature, " not found in column names of the training set."))
	
	ix <- match(feature, colnames(X))	
	x_new  <- X[,-ix]
	
        newdata	<- data.frame(X[,ix], check.names=F)
	colnames(newdata) <- feature
	
	is_factor <- sapply(x_new, class) == "factor"

	if (sum(!is_factor) > 0){
		numeric_df <- apply(data.frame(x_new[, !is_factor], check.names=F), 2, replace_continuous)
		colnames(numeric_df) <- colnames(x_new)[!is_factor]
		newdata <- data.frame(newdata, numeric_df, check.names=F)
	}

	if (sum(is_factor) > 0){
		factor_df <- apply(data.frame(x_new[, is_factor], check.names=F), 2, replace_factor)
		colnames(factor_df) <- colnames(x_new)[is_factor]
		newdata <- data.frame(newdata, factor_df, check.names=F)
	}

	
	# Remove duplicated features if predictor is a factor.
	# Only predict using unique factor levels	
	if (is.factor(newdata[,feature]))
		newdata <- newdata[!duplicated(newdata),]

	yh <- FUN(model, newdata, ...)
	
	if (!is.numeric(yh))
		stop("predict must return numeric matrix of class probabilities.")

	if (!is.null(dim(yh))){
		# This is a classification problem
		odds <- yh[,which.class]/(1-yh[,which.class])
	}else{
		odds <- yh
	}

	out <- data.frame(newdata[,feature], yhat=odds, check.names=F)
	colnames(out) <- c(feature, "yhat")

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
