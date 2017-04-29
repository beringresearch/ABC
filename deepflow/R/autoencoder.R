#' Learn a deep autoencoder
#'
#' @param x		Numeric expression matrix
#' @param seed 		Random seed integer
#' @import kerasR reticulate
#' @export

autoencoder <- function(x, seed=1234){
	
	np <- import("numpy")
	np$random$seed(integer(seed))


	x <- scale(x)
	set.seed(seed)
	x_noise <- x + matrix(runif(min=0, max=1, n=prod(dim(x))), ncol=ncol(x))
	
	encoder <- Sequential()
	encoder$add(Dense(units = 150,
			  activation="softsign",
			  input_shape=dim(x)[2],
			  kernel_initializer=glorot_uniform(seed=seed)))
	encoder$add(Dense(units = 150,
			  activation="softsign",
			  kernel_initializer=glorot_uniform(seed=seed)))
	encoder$add(Dense(units = 500,
			  activation="softsign",
			  kernel_initializer=glorot_uniform(seed=seed)))
	encoder$add(Dense(units = 4,
			  activation="linear",
			  kernel_initializer=glorot_uniform(seed=seed)))

	decoder <- Sequential()
	decoder$add(Dense(units = 500,
			  input_shape = 4,
			  activation="softsign",
			  kernel_initializer=glorot_uniform(seed=seed)))
	decoder$add(Dense(units = 150,	
			  activation="softsign",
			  kernel_initializer=glorot_uniform(seed=seed)))
	decoder$add(Dense(units = 150,	
			  activation="softsign",
			  kernel_initializer=glorot_uniform(seed=seed)))
	decoder$add(Dense(units = dim(x)[2],
			  activation="linear",
			  kernel_initializer=glorot_uniform(seed=seed)))
	
	autoencoder <- Sequential()
	autoencoder$add(encoder)
	autoencoder$add(decoder)
	
	early_stopping_cb <- list(EarlyStopping(monitor="loss", patience=10))

	keras_compile(autoencoder, loss = "mse", optimizer=Adam())
	keras_fit(autoencoder, x_noise, x,
		  epochs = 1000,
		  batch_size = 256,
		  shuffle = TRUE,
		  verbose=1, 
		  callbacks=early_stopping_cb)

	return(list(encoder=encoder, decoder=decoder, autoencoder=autoencoder))

}
