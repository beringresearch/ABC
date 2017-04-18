"""
deepcluster for flow cytometry.
"""

import os.path
import hdbscan
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

from sklearn.preprocessing import StandardScaler, Imputer
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import LabelEncoder

from keras import regularizers
from keras.utils import np_utils
from keras.models import Model
from keras.models import Sequential
from keras.layers import Input, Dense

from deepcytof.spinner import Spinner

def run(markers, files, weights, images_folder, logs_folder, cluster_size, nskip):
    np.random.seed(123)
    
    # Start the Spinner
    spinner = Spinner()
    spinner.start()

    # Initialise scikitlearn constructors
    min_max_scaler = StandardScaler()
    clf = IsolationForest(max_samples=256,
                          n_jobs=-1,
                          random_state=np.random.RandomState(42))
    impute_nas = Imputer()
    
    # Import marker names
    marker_names = np.genfromtxt(markers, dtype='str') 
    # Load the dataset
    data = pd.read_table(files, skiprows=nskip)
    tmp = np.arcsinh(data[marker_names].values/5)
    if np.isnan(tmp).any():
        tmp = impute_nas.fit_transform(tmp)
    
    tmp = min_max_scaler.fit_transform(tmp)
    clf.fit(tmp)
    noise = clf.predict(tmp)
    tmp = tmp[noise > 0]
    X = tmp

    # Define network achitecture
    input_img = Input(shape=(len(marker_names),))
    encoded = Dense(150, activation='softsign')(input_img)
    encoded = Dense(150, activation='softsign')(encoded)
    encoded = Dense(500, activation='softsign')(encoded)
    encoded = Dense(2, activation='linear',
            activity_regularizer=regularizers.l1(10e-5))(encoded)
    decoded = Dense(500, activation='softsign')(encoded)
    decoded = Dense(150, activation='softsign')(decoded)
    decoded = Dense(150, activation='softsign')(decoded)
    decoded = Dense(len(marker_names), activation='softsign')(decoded)
    
    # The main encoder model with the less important autoencoder
    encoder = Model(inputs=input_img, outputs=encoded)
    autoencoder = Model(inputs=input_img, outputs=decoded)
    autoencoder.compile(optimizer='adam', loss='mse')
    encoder.load_weights(weights)

    yh = encoder.predict(X)

    clusterer = hdbscan.HDBSCAN(min_cluster_size=cluster_size)
    cluster_labels = clusterer.fit_predict(yh)

    unclustered = cluster_labels == -1
    lblencoder = LabelEncoder()
    Y = cluster_labels[cluster_labels != -1]
    lblencoder.fit(Y)
    encoded_Y = lblencoder.transform(Y)
    dummy_y = np_utils.to_categorical(encoded_Y)
    X_test = yh[unclustered, ]
    X_train = yh[cluster_labels != -1]

    # Predict ramaining clusters
    model = Sequential()
    model.add(Dense(4, input_dim=2, kernel_initializer='normal', activation='relu'))
    model.add(Dense(dummy_y.shape[1], kernel_initializer='normal', activation='sigmoid'))
    model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])
    model.fit(X_train, dummy_y, epochs=20, verbose=0)

    cl = model.predict_classes(X_test, verbose=0)
    cluster_labels[unclustered] = cl

    fig = plt.figure()
    fig.add_subplot(111)
    hb = plt.scatter(yh[:,0], yh[:,1], c=cluster_labels,
            marker = '.', edgecolors='none', cmap='jet')
    plt.colorbar(hb)
    plt.savefig(images_folder+"/"+os.path.basename(files)+"_clustering.png")
    plt.close(fig)

    spinner.stop()
