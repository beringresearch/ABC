#' Learn a deep autoencoder
#'
#' @param x		Numeric expression matrix
#' @import kerasR
#' @export

autoencoder <- function(x){

	x <- scale(x)
	set.seed(1234)
	x_noise <- x + matrix(runif(min=0, max=1, n=prod(dim(x))), ncol=ncol(x))
	
	encoder <- Sequential()
	encoder$add(Dense(units = 150,
			  activation="softsign",
			  input_shape=dim(x)[2],
			  kernel_initializer=glorot_uniform(seed=1234)))
	encoder$add(Dense(units = 150,
			  activation="softsign",
			  kernel_initializer=glorot_uniform(seed=1234)))
	encoder$add(Dense(units = 500,
			  activation="softsign",
			  kernel_initializer=glorot_uniform(seed=1234)))
	encoder$add(Dense(units = 4,
			  activation="linear",
			  kernel_initializer=glorot_uniform(seed=1234)))

	decoder <- Sequential()
	decoder$add(Dense(units = 500,
			  input_shape = 4,
			  activation="softsign",
			  kernel_initializer=glorot_uniform(seed=1234)))
	decoder$add(Dense(units = 150,	
			  activation="softsign",
			  kernel_initializer=glorot_uniform(seed=1234)))
	decoder$add(Dense(units = 150,	
			  activation="softsign",
			  kernel_initializer=glorot_uniform(seed=1234)))
	decoder$add(Dense(units = dim(x)[2],
			  activation="linear",
			  kernel_initializer=glorot_uniform(seed=1234)))
	
	autoencoder <- Sequential()
	autoencoder$add(encoder)
	autoencoder$add(decoder)
	
	early_stopping_cb <- list(EarlyStopping(monitor="loss", patience=10))

	keras_compile(autoencoder, loss = "mse", optimizer=Adam())
	keras_fit(autoencoder, x_noise, x,
		  epochs = 250,
		  batch_size = 256,
		  shuffle = FALSE,
		  verbose=1, 
		  callbacks=early_stopping_cb)

	return(list(encoder=encoder, decoder=decoder, autoencoder=autoencoder))

}
