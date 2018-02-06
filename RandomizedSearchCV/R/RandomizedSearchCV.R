#' Randomized search CV
#' @param X
#' @param Y
#' @param estimator
#' @param param_distributions
#' @param n_iter
#' @param cv
#' @pram seed

RandomizedSearchCV <- function(estimator, param_distributions,
                               n_iter=10, cv=5)
