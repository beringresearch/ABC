package com.bering.deepflow.neuralNetworks;

import org.deeplearning4j.api.storage.StatsStorage;
import org.deeplearning4j.nn.api.OptimizationAlgorithm;
import org.deeplearning4j.nn.conf.GradientNormalization;
import org.deeplearning4j.nn.conf.MultiLayerConfiguration;
import org.deeplearning4j.nn.conf.NeuralNetConfiguration;
import org.deeplearning4j.nn.conf.layers.AutoEncoder;
import org.deeplearning4j.nn.conf.layers.OutputLayer;
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork;
import org.deeplearning4j.nn.weights.WeightInit;
import org.deeplearning4j.optimize.listeners.ScoreIterationListener;
import org.deeplearning4j.ui.api.UIServer;
import org.deeplearning4j.ui.stats.StatsListener;
import org.deeplearning4j.ui.storage.InMemoryStatsStorage;
import org.nd4j.linalg.api.ndarray.INDArray;
import org.nd4j.linalg.dataset.DataSet;
import org.nd4j.linalg.lossfunctions.LossFunctions;

import java.io.File;
import java.util.Collections;

/**
 * Created by benjamin on 24/03/17.
 */
public class StackedDenoisingAutoencoder {

    int seed = 123;
    int iterations = 1;

    public StackedDenoisingAutoencoder(){


        try {
            process();
        } catch (Exception e) {System.out.println(e.getMessage());}
    }

    public void process() {

        DataSet dataSet = new DataSet();
        dataSet.load(new File("c11_S001visit1_CD8+ cells.fcs_raw_events_processed"));
        INDArray featureMatrix = dataSet.getFeatures();
        //System.out.println(featureMatrix);
        final int rows = featureMatrix.rows();
        final int cols = featureMatrix.columns();
        System.out.println("No. of rows: " + rows);
        System.out.println("No. of cols: " + cols);

        MultiLayerConfiguration conf = new NeuralNetConfiguration.Builder()
                .seed(seed)
                .gradientNormalization(GradientNormalization.ClipElementWiseAbsoluteValue)
                .gradientNormalizationThreshold(1.0)
                .iterations(iterations)
                .momentum(0.5)
                .momentumAfter(Collections.singletonMap(3, 0.9))
                .optimizationAlgo(OptimizationAlgorithm.CONJUGATE_GRADIENT)
                .list()
                .layer(0, new AutoEncoder.Builder().nIn(rows * cols).nOut(500)
                        .weightInit(WeightInit.XAVIER).lossFunction(LossFunctions.LossFunction.RMSE_XENT)
                        .corruptionLevel(0.3)
                        .build())
                .layer(1, new AutoEncoder.Builder().nIn(500).nOut(250)
                        .weightInit(WeightInit.XAVIER).lossFunction(LossFunctions.LossFunction.RMSE_XENT)
                        .corruptionLevel(0.3)

                        .build())
                .layer(2, new AutoEncoder.Builder().nIn(250).nOut(200)
                        .weightInit(WeightInit.XAVIER).lossFunction(LossFunctions.LossFunction.RMSE_XENT)
                        .corruptionLevel(0.3)
                        .build())
                .layer(3, new OutputLayer.Builder(LossFunctions.LossFunction.NEGATIVELOGLIKELIHOOD).activation("softmax")
                        .nIn(200).nOut(rows * cols).build())
                .pretrain(true).backprop(false)
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

        model.fit(dataSet.getFeatures());
    }
}
