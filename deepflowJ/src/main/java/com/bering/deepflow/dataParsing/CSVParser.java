package com.bering.deepflow.dataParsing;

import org.datavec.api.records.reader.RecordReader;
import org.datavec.api.records.reader.impl.csv.CSVRecordReader;
import org.datavec.api.split.FileSplit;
import org.deeplearning4j.datasets.datavec.RecordReaderDataSetIterator;
import org.nd4j.linalg.dataset.DataSet;
import org.nd4j.linalg.dataset.api.iterator.DataSetIterator;
import org.nd4j.linalg.dataset.api.preprocessor.DataNormalization;
import org.nd4j.linalg.dataset.api.preprocessor.NormalizerMinMaxScaler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.datavec.api.records.reader.impl.LineRecordReader;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

/**
 * Created by benjamin on 23/03/17.
 *
 * Responsible for parsing a CSV file to extract a DataSet object, it applies transformations and normalizations to the data-set.
 * These include:
 *  - applying a mask
 *  - applying a arcsinh(x/covariant) transform, where the covariant is 5.
 *  - applying a MinMaxScaler to bring all values of the data-set within the range (0,1).
 * Upon completion, it saves the processed data-set in binary with the DataSet.save() method.
 * It also saves a list of features for the data-set.
 *
 * It takes as arguments:
 * 1) The filepath to the .csv file containing the data
 * 2) The number of lines to skip in that file to reach the first row of that data
 * 3) (Optional) A list of features for the data-set, those not present will be filtered out
 */
public class CSVParser {

    private static Logger log = LoggerFactory.getLogger(CSVParser.class);

    String filepath;
    int linesToSkip;
    boolean[] mask;

    public CSVParser(String filepath, int linesToSkip, String featureFilePath) {
        this.filepath = filepath;
        this.linesToSkip = linesToSkip;
        this.mask = findFeatureMask(filepath, featureFilePath, ",");

        try {
            this.processData(filepath, linesToSkip, mask);
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }

    public CSVParser(String filepath, int linesToSkip){
        this.filepath = filepath;
        this.linesToSkip = linesToSkip;

        try {
            this.processData(filepath, linesToSkip, mask);
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }

    public CSVParser(){}

    void processData(String filepath, int numLinesToSkip, boolean[] mask) throws Exception {

        long startTime = System.nanoTime();

        // First, get the dataset using the record reader. CSVRecordReader handles logging/parsing
        String delimiter = ",";
        RecordReader recordReader = new CSVRecordReader(numLinesToSkip, delimiter);
        recordReader.initialize(new FileSplit(new File(filepath)));
        System.out.println("Done reading file.");

        String[] features = getFeatures(filepath, numLinesToSkip, delimiter);
        if (mask != null) {
            features = Transforms.applyFeatureMask(mask, features);
        }
        saveFeatures(features, filepath);


        // Second, the RecordReaderDataSetIterator handles conversion to DataSet objects, ready for use in neural network.
        int batchSize = 10000;

        // Store intermediate results in arrayList
        ArrayList<DataSet> dataSetArrayList = new ArrayList<DataSet>();

        DataSetIterator iterator = new RecordReaderDataSetIterator(recordReader, batchSize);
        DataSet dataSet;

        while(iterator.hasNext()) {
            dataSet = iterator.next();
            if (mask != null)
                dataSet = Transforms.applyMask(mask, dataSet);
            dataSet = Transforms.arcsinh(dataSet, 5);
            dataSetArrayList.add(dataSet);
        }

        // Combine intermediate results into one, normalize by applying MinMaxScaler to scale features between 0 and 1.
        DataNormalization normalizer = new NormalizerMinMaxScaler(0.00, 1.00);
        DataSet allData  = DataSet.merge(dataSetArrayList);
        normalizer.fit(allData);
        normalizer.transform(allData);

        //System.out.println(allData.getFeatures());
        System.out.println("DONE.");

        long endTime = System.nanoTime();
        long duration = (endTime - startTime);
        System.out.println("TIME ELAPSED: " + duration / 1000000000.0 + " seconds.");

        System.out.println("Saving dataset");
        allData.save(new File( filepath + "_processed"));

    }

    public String[] getFeatures(String filepath, int numLinesToSkip, String delimiter) throws IOException, InterruptedException{
        // Look at first lines for meta-data, including Markers.
        LineRecordReader lineRecordReader = new LineRecordReader();
        lineRecordReader.initialize(new FileSplit(new File(filepath)));

        for(int i=0; i<numLinesToSkip -1 ; i++) lineRecordReader.next();

        String featureString = lineRecordReader.next().toString();
        String[] features = featureString.substring(1, featureString.length() -1).split(delimiter);

        return features;
    }

    DataSet loadDataSet(String filepath) {
        System.out.println("Loading dataset");
        DataSet dataSet = new DataSet();
        dataSet.load(new File(filepath));
        return dataSet;
    }

    private void saveFeatures(String[] features, String filepath) {

        File file = new File(filepath+"_features.csv");
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
            for (int i=0; i<features.length-1; i++) {
                writer.write(features[i]+",");
            }
            writer.write(features[features.length-1]);
        } catch (IOException e) {
            System.out.println(e.getMessage());
        }

    }

    boolean[] findFeatureMask(String dataFile, String featureFile, String delimiter){
        String[] dataFeatures;
        String[] featureList;

        try {
            dataFeatures = getFeatures(dataFile, linesToSkip, delimiter);
            featureList = parseFeatureListFile(featureFile, delimiter);
            boolean[] mask = new boolean[dataFeatures.length];

            for(int i=0; i<dataFeatures.length; i++)
                mask[i] = stringInArray(dataFeatures[i], featureList);

            return mask;

        } catch(Exception e ){
            System.out.println(e.getMessage());
        }

        return null;

    }

    private String[] parseFeatureListFile(String filepath, String delimiter) throws IOException, InterruptedException{
        LineRecordReader lineRecordReader = new LineRecordReader();
        lineRecordReader.initialize(new FileSplit(new File(filepath)));

        String featureString = lineRecordReader.next().toString();
        String[] featureList = featureString.substring(1, featureString.length() - 1).split(delimiter);

        return featureList;
    }

    private boolean stringInArray(String str, String[] array) {
        for (String string : array) {
            if (string.equals(str)) {
                return true;
            }
        }

        return false;
    }


}