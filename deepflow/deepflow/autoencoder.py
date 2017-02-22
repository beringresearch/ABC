""" run trains the variational autoencoder on all input text and saves the resulting 2D graphs in the folder specified in the output_path.
    text_files is expected to be a list of absolute-paths to text files, with each path being a string.
    output_path is expected to be a string that points to a folder, in which the generated images will be saved. """

def run(text_files, output_path):
    import matplotlib.pyplot as plt
    import pandas as pd
    import numpy as np

    from sklearn.preprocessing import MinMaxScaler

    from keras.models import Model
    from keras.layers import Input, Dense
    from keras.callbacks import EarlyStopping
    from keras import backend as K

    np.random.seed(123)

    listing = text_files
    min_max_scaler = MinMaxScaler()
    X = []
    data = pd.read_table(listing[0])
    markers = data.columns[3:]

    for filename in listing:
        data = pd.read_table(filename)
        tmp = data.values[:, 3:]
        X.append(min_max_scaler.fit_transform(tmp))


    input_img = Input(shape=(X[0].shape[1],))
    encoded = Dense(20, activation='tanh')(input_img)
    encoded = Dense(10, activation='tanh')(encoded)
    encoded = Dense(5, activation='tanh')(encoded)
    encoded = Dense(2, activation='tanh')(encoded)
    decoded = Dense(5, activation='tanh')(encoded)
    decoded = Dense(10, activation='tanh')(decoded)
    decoded = Dense(20, activation='tanh')(decoded)
    decoded = Dense(X[0].shape[1], activation='tanh')(decoded)

    early_stopping = EarlyStopping(monitor='val_loss', min_delta=0,
                                patience=10, verbose=1, mode='auto')
    encoder = Model(input=input_img, output=encoded)
    autoencoder = Model(input=input_img, output=decoded)
    autoencoder.compile(optimizer='adam', loss='mse')

    deepflow = []
    for x in X:
        fit = autoencoder.fit(x, x, nb_epoch=500,
                            shuffle=True, validation_data=(x, x),
                            callbacks=[early_stopping],
                            verbose = 1)
        yh = encoder.predict(x)
        deepflow.append(yh)


    print("Saving graphs...")
    fig, axs = plt.subplots(3, 3, figsize=(25, 20), facecolor='w', edgecolor='k')
    fig.subplots_adjust(hspace=.1, wspace=.1)
    axs = axs.ravel()

    time_point = ["Baseline", "Day 15", "Day 45", "", "", "", "", "", ""]

    for mix in range(X[0].shape[1]):
        plt.cla()
        fig, axs = plt.subplots(3, 3,
                                figsize=(25, 20))
        fig.subplots_adjust(hspace=.1, wspace=.1)
        axs = axs.ravel()
        for k in range(len(deepflow)):
            yh = deepflow[k]
            tmp = X[k]
            m = tmp[:, mix]
            hb = axs[k].hexbin(yh[:, 0], yh[:, 1], C=m, gridsize=50)
            axs[k].set_title(time_point[k])
            fig.colorbar(hb, ax=axs[k])
        plt.savefig(output_path+str(markers[mix])+"_pbmc_deepflow.png")
        plt.close(fig)

    # Explicitly close the session to avoid intermittent exceptions thrown by Tensorflow
    # K.clear_session()
