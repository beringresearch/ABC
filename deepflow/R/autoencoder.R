#' Learn a deep autoencoder
#'
#' @param x		Numeric expression matrix
#' @param hidden 	Vector of neurons in the hidden layer(s)
#' @param activation	Vector of hidden layer activations
#' @param epochs 	Number of training epochs
#' @import kerasR
#' @export

autoencoder <- function(x, hidden = c(150, 150, 500, 4),
			activation = c("softsign", "softsign", "softsign", "linear"),
			epochs=100){

	x <- scale(x)
	
	# Encoder
	encoder <- Sequential()
	encoder$add(Dense(units=hidden[1], activation="linear", input_shape=dim(x)[2]))
	for (n in 2:length(hidden)){
		encoder$add(Dense(units=hidden[n],
				activation=activation[n]))
	}

	# Decoder
	decoder <- Sequential()
	decoder$add(Dense(units=hidden[length(hidden)-1],
			  activation=activation[length(hidden)-1],
			  input_shape=hidden[length(hidden)]))
	for (n in length(hidden)-1 : 1){
		decoder$add(Dense(units=hidden[n],
				  activation=activation[n]))
	}
	decoder$add(Dense(units=dim(x)[2]))

	autoencoder <- Sequential()
	autoencoder$add(encoder)
	autoencoder$add(decoder)

	keras_compile(autoencoder, loss = "mse", optimizer=Adam())
	keras_fit(autoencoder, x, x, epochs = epochs, verbose=1)

	return(list(encoder=encoder, decoder=decoder, autoencoder=autoencoder))

}
