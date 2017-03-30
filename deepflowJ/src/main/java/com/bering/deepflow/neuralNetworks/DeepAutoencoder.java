package com.bering.deepflow.neuralNetworks;

import com.bering.deepflow.dataParsing.CSVParser;
import org.deeplearning4j.api.storage.StatsStorage;
import org.deeplearning4j.ui.api.UIServer;
import org.deeplearning4j.ui.stats.StatsListener;
import org.deeplearning4j.ui.storage.InMemoryStatsStorage;
import org.nd4j.linalg.activations.Activation;

import org.deeplearning4j.nn.api.OptimizationAlgorithm;
import org.deeplearning4j.nn.conf.MultiLayerConfiguration;
import org.deeplearning4j.nn.conf.NeuralNetConfiguration;
import org.deeplearning4j.nn.conf.Updater;
import org.deeplearning4j.nn.conf.layers.DenseLayer;
import org.deeplearning4j.nn.conf.layers.OutputLayer;
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork;
import org.deeplearning4j.nn.weights.WeightInit;
import org.deeplearning4j.optimize.api.IterationListener;
import org.deeplearning4j.optimize.listeners.ScoreIterationListener;
import org.nd4j.linalg.api.ndarray.INDArray;
import org.nd4j.linalg.dataset.DataSet;

import org.nd4j.linalg.lossfunctions.LossFunctions;


import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.*;
import java.util.List;

/** A DeepAutoencoder, which takes high-dimensional data and encodes it into 2-dimensions, ready for visualization.
 *  These encodings are then saved to a folder, "encodings" below where the program was called from.
 *
 *  The input is the path to a pre-processed dataSet, normalized and saved by the DataSet.save() method, and ready to be fed into a neural network.
 *
 * @author Benjamin Szubert
 */
public class DeepAutoencoder {

    public DeepAutoencoder(String dataSetFile) {
        try{
            process(dataSetFile);
        }catch (Exception e ) {
            System.out.println(e.getMessage());
        }
    }

    void process(String dataSetFile) throws Exception {

        Random r = new Random(12345);

        DataSet dataSet = new DataSet();
        dataSet.load(new File(dataSetFile));
        INDArray featureMatrix = dataSet.getFeatures();

        // Data needs to be transposed: the rows and columns must be flipped.
        featureMatrix = featureMatrix.transposei();
        dataSet.setFeatures(featureMatrix);

        final int rows = featureMatrix.rows();
        final int cols = featureMatrix.columns();
        System.out.println("No. of rows: " + rows);
        System.out.println("No. of cols: " + cols);
        List<DataSet> datasetList = dataSet.batchBy(45);


        List<INDArray> featuresTrain = new ArrayList<>();
        List<INDArray> featuresTest = new ArrayList<>();

        Iterator<DataSet> iterator =   datasetList.iterator();
        while (iterator.hasNext()){
            DataSet ds = iterator.next();       // Normally would split into test and train data, but here we use all
            featuresTrain.add(ds.getFeatures());
        }


        //Set up network.
        MultiLayerConfiguration conf = new NeuralNetConfiguration.Builder()
                .seed(12345)
                .iterations(1)
                .weightInit(WeightInit.XAVIER)
                .updater(Updater.ADAGRAD)
                .activation(Activation.TANH)
                .optimizationAlgo(OptimizationAlgorithm.STOCHASTIC_GRADIENT_DESCENT)
                .learningRate(0.05)
                .regularization(true).l2(0.0001)
                .list()
                .layer(0, new DenseLayer.Builder().nIn(cols).nOut(20)
                        .build())
                .layer(1, new DenseLayer.Builder().nIn(20).nOut(10)
                        .build())
                .layer(2, new DenseLayer.Builder().nIn(10).nOut(4)
                        .build())
                .layer(3, new DenseLayer.Builder().nIn(4).nOut(2)
                        .build())
                .layer(4, new DenseLayer.Builder().nIn(2).nOut(4)
                        .build())
                .layer(5, new DenseLayer.Builder().nIn(4).nOut(10)
                        .build())
                .layer(6, new DenseLayer.Builder().nIn(10).nOut(20)
                        .build())
                .layer(7, new OutputLayer.Builder().nIn(20).nOut(cols)
                        .lossFunction(LossFunctions.LossFunction.MSE)
                        .build())
                .pretrain(false).backprop(true)
                .build();

        MultiLayerNetwork net = new MultiLayerNetwork(conf);
        net.setListeners(Collections.singletonList((IterationListener) new ScoreIterationListener(1)));

        //Initialize the user interface backend
        UIServer uiServer = UIServer.getInstance();

        //Configure where the network information (gradients, score vs. time etc) is to be stored. Here: store in memory.
        StatsStorage statsStorage = new InMemoryStatsStorage();         //Alternative: new FileStatsStorage(File), for saving and loading later

        //Attach the StatsStorage instance to the UI: this allows the contents of the StatsStorage to be visualized
        uiServer.attach(statsStorage);

        //Then add the StatsListener to collect this information from the network, as it trains
        net.setListeners(new StatsListener(statsStorage));



        //Train model:
        int nEpochs = 250;
        for( int epoch=0; epoch<nEpochs; epoch++ ){
            for(INDArray data : featuresTrain){
                net.fit(data,data);
            }
            System.out.println("Epoch " + epoch + " complete");
        }

        CSVParser parser = new CSVParser();
        String[] featureList = parser.getFeatures("c11_S001visit1_CD8+ cells.fcs_raw_events_featureList.csv", 0, ",");


        List<INDArray> encodingsList = new ArrayList<INDArray>();

        for (int i=0; i<featureMatrix.rows(); i++) {
            INDArray input = featureMatrix.getRow(i);
            INDArray activation = net.activateSelectedLayers(0,net.getnLayers() / 2 - 1, input);
            System.out.println(featureList[i]);
            System.out.println(activation);
            encodingsList.add(activation);
        }

        this.saveFeatureEncodings(featureList, encodingsList);

    }

    private void saveFeatureEncodings(String[] features, List<INDArray>twoDimensionalEncodings) {

        System.out.println("SAVING FILES");
        String folderName = "encodings";
        File pwd = new File(Paths.get(".").toAbsolutePath().normalize().toString());
        File dir = new File(pwd, folderName);
        dir.mkdir();


        for (int i=0; i<twoDimensionalEncodings.size(); i++) {
            File file = new File(dir, features[i] + "_encoding.csv");
            INDArray encoding = twoDimensionalEncodings.get(i);

            try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
                for (int j = 0; j < encoding.columns() - 1; j++) {
                    writer.write(encoding.getDouble(j) + ",");
                }
                writer.write(Double.toString(encoding.getDouble(encoding.columns() - 1)));
            } catch (IOException e) {
                System.out.println(e.getMessage());
            }
        }

    }

}
