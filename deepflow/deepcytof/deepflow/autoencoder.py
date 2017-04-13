"""
deepflow for flow cytometry.

run trains a deep autoencoder on all input text and saves
the resulting 2D graphs in the folder specified in the output_path.
text_files is expected to be a list of absolute-paths to text files,
with each path being a string.

output_path is expected to be a string that points to a folder, in
which the generated images will be saved.
"""

import os.path
import sys
import multiprocessing

import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

from sklearn.preprocessing import Imputer, StandardScaler
from sklearn.ensemble import IsolationForest

#from keras import regularizers
from keras.models import Model
from keras.layers import Input, Dense
from keras.callbacks import EarlyStopping

from deepcytof.spinner import Spinner

import theano
theano.config.openmp = True
OMP_NUM_THREADS=multiprocessing.cpu_count()

def run(markers, text_files, nskip, images_path, logs_path):
    """Main algo."""

    np.random.seed(123)
    
    # Initialise scikitlearn constructors
    min_max_scaler = StandardScaler()
    clf = IsolationForest(max_samples=256,
                          n_jobs=-1,
                          random_state=np.random.RandomState(42))
    impute_nas = Imputer()

    X = [] 
    marker_names = np.genfromtxt(markers, dtype='str')
 
    
    # Read in data
    for filename in text_files:
        data = pd.read_table(filename, skiprows=nskip)
        tmp = np.arcsinh(data[marker_names].values/5) 
        if np.isnan(tmp).any():
            tmp = impute_nas.fit_transform(tmp)
        tmp = min_max_scaler.fit_transform(tmp)
        clf.fit(tmp)
        noise = clf.predict(tmp)
        tmp = tmp[noise > 0,]
        X.append(tmp) 
     
    deepflow = []
    fit = []
    model = []
    
    # Train the autoencoder on each dataset
    sys.stdout.write("Learning file structure...")
    spinner = Spinner()
    spinner.start()

    for x in X:
        # Define network architecture
        input_img = Input(shape=(len(marker_names),))
        encoded = Dense(20, activation='softsign')(input_img)
        encoded = Dense(10, activation='softsign')(encoded)
        encoded = Dense(4, activation='softsign')(encoded)
        encoded = Dense(2, activation='linear')(encoded)
        decoded = Dense(4, activation='softsign')(encoded)
        decoded = Dense(10, activation='softsign')(decoded) 
        decoded = Dense(20, activation='softsign')(decoded)
        decoded = Dense(len(marker_names), activation='softsign')(decoded)
        # Early stopping criteria
        early_stopping = EarlyStopping(monitor='val_loss', min_delta=0,
                                   patience=10, mode='auto')
        # The main encoder model with the less important autoencoder
        encoder = Model(inputs=input_img, outputs=encoded)
        autoencoder = Model(inputs=input_img, outputs=decoded)
        autoencoder.compile(optimizer='adam', loss='mse')
        f = autoencoder.fit(x, x, epochs=250,
                        shuffle=True, validation_data=(x, x),
                        callbacks=[early_stopping],
                        verbose=0)
        fit.append(f)
        yh = encoder.predict(x) 
        deepflow.append(yh)
        model.append(encoder)

    spinner.stop()
    sys.stdout.write("FINISHED")

    # Generate images and save model weights
    sys.stdout.write("\nSaving weights and generating images...")
    spinner = Spinner()
    spinner.start()
    for k in range(len(deepflow)):
        fig = plt.figure()
        fig.suptitle(os.path.basename(text_files[k]), fontsize=14)
        fig.add_subplot(111)
        f = fit[k]
        plt.plot(f.history['loss'])
        plt.xlabel('Iteration')
        plt.ylabel('Loss')
        plt.savefig(logs_path +
                    os.path.basename(text_files[k])+"_loss.png")
        plt.close(fig)
        model[k].save_weights(logs_path + 
                              os.path.basename(text_files[k])+"_weights.h5")


        for marker in range(X[0].shape[1]):
            plt.cla()
            yh = deepflow[k]
            tmp = X[k]
            marker_expression = tmp[:, marker]

            fig = plt.figure()
            fig.suptitle(marker_names[marker], fontsize=14)
            fig.add_subplot(111)
            hb = plt.scatter(yh[:, 0], yh[:, 1], c=marker_expression,
                            marker = '.', edgecolors='none', cmap="jet")
            plt.colorbar(hb)
            plt.savefig(images_path+os.path.basename(text_files[k]) +
                        "_"+marker_names[marker]+str()+".png")
            plt.close(fig)
    spinner.stop()
    sys.stdout.write("FINISHED\n")


