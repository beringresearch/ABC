package com.bering.deepflow.neuralNetworks;

/**
 * Created by benjamin on 24/03/17.
 */

import org.deeplearning4j.api.storage.StatsStorage;
import org.deeplearning4j.datasets.fetchers.MnistDataFetcher;
import org.deeplearning4j.datasets.iterator.impl.MnistDataSetIterator;
import org.deeplearning4j.nn.api.OptimizationAlgorithm;
import org.deeplearning4j.nn.conf.MultiLayerConfiguration;
import org.deeplearning4j.nn.conf.NeuralNetConfiguration;
import org.deeplearning4j.nn.conf.layers.OutputLayer;
import org.deeplearning4j.nn.conf.layers.RBM;
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork;
import org.deeplearning4j.optimize.listeners.ScoreIterationListener;
import org.deeplearning4j.ui.api.UIServer;
import org.deeplearning4j.ui.stats.StatsListener;
import org.deeplearning4j.ui.storage.InMemoryStatsStorage;
import org.nd4j.linalg.activations.Activation;
import org.nd4j.linalg.api.ndarray.INDArray;
import org.nd4j.linalg.dataset.DataSet;
import org.nd4j.linalg.dataset.api.iterator.DataSetIterator;
import org.nd4j.linalg.lossfunctions.LossFunctions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.deeplearning4j.datasets.fetchers.MnistDataFetcher;
import org.deeplearning4j.datasets.iterator.impl.MnistDataSetIterator;
import org.deeplearning4j.nn.api.OptimizationAlgorithm;
import org.deeplearning4j.nn.conf.MultiLayerConfiguration;
import org.deeplearning4j.nn.conf.NeuralNetConfiguration;
import org.deeplearning4j.nn.conf.layers.OutputLayer;
import org.deeplearning4j.nn.conf.layers.RBM;
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork;
import org.deeplearning4j.optimize.api.IterationListener;
import org.deeplearning4j.optimize.listeners.ScoreIterationListener;
import org.nd4j.linalg.activations.Activation;
import org.nd4j.linalg.dataset.DataSet;
import org.nd4j.linalg.dataset.api.iterator.DataSetIterator;
import org.nd4j.linalg.lossfunctions.LossFunctions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

/**
 * ***** NOTE: This example has not been tuned. It requires additional work to produce sensible results *****
 *
 * @author Adam Gibson
 */
public class DeepAutoencoder{

    private static Logger log = LoggerFactory.getLogger(DeepAutoencoder.class);

    public DeepAutoencoder(){


        try {
            process();
        } catch (Exception e) {System.out.println(e.getMessage());}
    }

    public void process () throws Exception {
        int seed = 123;
        int iterations = 1;

        DataSet dataSet = new DataSet();
        dataSet.load(new File("c11_S001visit1_CD8+ cells.fcs_raw_events_processed"));
        INDArray featureMatrix = dataSet.getFeatures();
        //System.out.println(featureMatrix);
        final int rows = featureMatrix.rows();
        final int cols = featureMatrix.columns();
        System.out.println("No. of rows: " + rows);
        System.out.println("No. of cols: " + cols);

        List<DataSet> datasetList = dataSet.batchBy(45);

        log.info("Build model....");
        MultiLayerConfiguration conf = new NeuralNetConfiguration.Builder()
                .seed(seed)
                .iterations(iterations)
                .optimizationAlgo(OptimizationAlgorithm.LINE_GRADIENT_DESCENT)
                .list()
                .layer(0, new RBM.Builder().nIn(45).nOut(45)
                        .lossFunction(LossFunctions.LossFunction.MSE)
                        .activation(Activation.SIGMOID)
                        .build())
                .layer(1, new RBM.Builder().nIn(45).nOut(10)
                        .lossFunction(LossFunctions.LossFunction.MSE)
                        .activation(Activation.SIGMOID)
                        .build())
                .layer(2, new RBM.Builder().nIn(10).nOut(4)
                        .lossFunction(LossFunctions.LossFunction.MSE)
                        .activation(Activation.SIGMOID)
                        .build())
                .layer(3, new RBM.Builder().nIn(4).nOut(2)
                        .lossFunction(LossFunctions.LossFunction.MSE)
                        .activation(Activation.SIGMOID)
                        .build())
                .layer(4, new RBM.Builder().nIn(2).nOut(4)  //decode
                        .lossFunction(LossFunctions.LossFunction.MSE)
                        .activation(Activation.SIGMOID)
                        .build())
                .layer(5, new RBM.Builder().nIn(4).nOut(10)
                        .lossFunction(LossFunctions.LossFunction.MSE)
                        .build())
                .layer(6, new RBM.Builder().nIn(10).nOut(45)
                        .lossFunction(LossFunctions.LossFunction.MSE)
                        .build())
                .layer(7, new OutputLayer
                        .Builder(LossFunctions.LossFunction.MSE).activation(Activation.SIGMOID).nIn(45).nOut(45)
                        .build())
                .pretrain(true).backprop(true)
                .build();

        MultiLayerNetwork model = new MultiLayerNetwork(conf);
        model.init();

        model.setListeners(new ScoreIterationListener(1/5));

        //Initialize the user interface backend
        UIServer uiServer = UIServer.getInstance();

        //Configure where the network information (gradients, score vs. time etc) is to be stored. Here: store in memory.
        StatsStorage statsStorage = new InMemoryStatsStorage();         //Alternative: new FileStatsStorage(File), for saving and loading later

        //Attach the StatsStorage instance to the UI: this allows the contents of the StatsStorage to be visualized
        uiServer.attach(statsStorage);

        //Then add the StatsListener to collect this information from the network, as it trains
        model.setListeners(new StatsListener(statsStorage));

        log.info("Train model....");

        //model.fit(dataSet.getFeatures());
        Iterator<DataSet> iterator =   datasetList.iterator();
        while (iterator.hasNext()){
            DataSet next = iterator.next();
            model.fit(new DataSet(next.getFeatures(), next.getFeatures()));
        }

        log.info("DONE");



    }




}

