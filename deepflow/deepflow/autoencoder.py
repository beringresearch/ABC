"""
deepflow for flow cytometry.

run trains the variational autoencoder on all input text and saves
the resulting 2D graphs in the folder specified in the output_path.
text_files is expected to be a list of absolute-paths to text files,
with each path being a string.

output_path is expected to be a string that points to a folder, in
which the generated images will be saved.
"""

import os.path
import sys
import time
import threading

import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

from sklearn.preprocessing import MinMaxScaler

from keras.models import Model
from keras.layers import Input, Dense
from keras.callbacks import EarlyStopping


def run(markers, text_files, output_path):
    """Main algo."""
    np.random.seed(123)

    listing = text_files
    min_max_scaler = MinMaxScaler()
    X = []
    data = pd.read_table(listing[0], skiprows=1)
    marker_names = np.genfromtxt(markers, dtype='str')

    for filename in listing:
        data = pd.read_table(filename, skiprows=1)
        tmp = np.arcsinh(data[marker_names].values/5)
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
                                   patience=10, mode='auto')
    encoder = Model(input=input_img, output=encoded)
    autoencoder = Model(input=input_img, output=decoded)
    autoencoder.compile(optimizer='adam', loss='mse')

    deepflow = []

    sys.stdout.write("Learning file structure...")
    spinner = Spinner()
    spinner.start()
    for x in X:
        autoencoder.fit(x, x, nb_epoch=500,
                        shuffle=True, validation_data=(x, x),
                        callbacks=[early_stopping],
                        verbose=0)
        yh = encoder.predict(x)
        deepflow.append(yh)
    spinner.stop()
    sys.stdout.write("FINISHED")
    sys.stdout.write("\nGenerating images...")
    spinner = Spinner()
    spinner.start()
    for k in range(len(deepflow)):
        for marker in range(X[0].shape[1]):
            plt.cla()
            yh = deepflow[k]
            tmp = X[k]
            marker_expression = tmp[:, marker]

            fig = plt.figure()
            fig.suptitle(marker_names[marker], fontsize=14)
            fig.add_subplot(111)
            hb = plt.hexbin(yh[:, 0], yh[:, 1], C=marker_expression,
                            gridsize=50, cmap="jet")
            plt.colorbar(hb)
            plt.savefig(output_path+os.path.basename(text_files[k]) +
                        "_"+str(marker_names[marker])+".png")
            plt.close(fig)
    spinner.stop()
    sys.stdout.write("FINISHED\n")

class Spinner:
    """Add a pretty spinner to indicate progress, because why not :) ."""

    busy = False
    delay = 0.1

    @staticmethod
    def spinning_cursor():
        """Spinning cursror running in a separate thread."""
        while 1:
            for cursor in '|/-\\':
                yield cursor

    def __init__(self, delay=None):
        """Constructor."""
        self.spinner_generator = self.spinning_cursor()
        if delay and float(delay):
            self.delay = delay

    def spinner_task(self):
        """Task definition."""
        while self.busy:
            sys.stdout.write(next(self.spinner_generator))
            sys.stdout.flush()
            time.sleep(self.delay)
            sys.stdout.write('\b')
            sys.stdout.flush()

    def start(self):
        """Start spinner."""
        self.busy = True
        threading.Thread(target=self.spinner_task).start()

    def stop(self):
        """Stop spinnner."""
        self.busy = False
        time.sleep(self.delay)
