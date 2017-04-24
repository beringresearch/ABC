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
	encoder$add(Dense(units=hidden[1],
			  activation="linear",
			  input_shape=dim(x)[2],
			  kernel_initializer=glorot_uniform(seed=1234)))
	for (n in 2:length(hidden)){
		encoder$add(Dense(units=hidden[n],
				activation=activation[n],
				kernel_initializer=glorot_uniform(seed=1234)))
	}

	# Decoder
	decoder <- Sequential()
	decoder$add(Dense(units=hidden[length(hidden)-1],
			  activation=activation[length(hidden)-1],
			  input_shape=hidden[length(hidden)],
			  kernel_initializer=glorot_uniform(seed=1234)))
	for (n in length(hidden)-1 : 1){
		decoder$add(Dense(units=hidden[n],
				  activation=activation[n],
				  kernel_initializer=glorot_uniform(seed=1234)))
	}
	decoder$add(Dense(units=dim(x)[2],
			  kernel_initializer=glorot_uniform(seed=1234)))

	autoencoder <- Sequential()
	autoencoder$add(encoder)
	autoencoder$add(decoder)

	keras_compile(autoencoder, loss = "mse", optimizer=Adam())
	keras_fit(autoencoder, x, x,
		  epochs = epochs,
		  shuffle = FALSE,
		  verbose=1)

	return(list(encoder=encoder, decoder=decoder, autoencoder=autoencoder))

}
