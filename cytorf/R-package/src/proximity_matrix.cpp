#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericMatrix rcpp_proximity_matrix(NumericMatrix idx) {
	int nrow = idx.nrow(), ncol = idx.nrow();
	NumericMatrix proximity(nrow, ncol);
	
	for (int i = 0; i < nrow; i++) {
		for (int j = 0; j < ncol; j++) {	
			NumericVector nodei = idx(i,_);
			NumericVector nodej = idx(j,_);
			proximity(i, j) = sum(nodei == nodej);
		}
	}
	
	return proximity;
}
