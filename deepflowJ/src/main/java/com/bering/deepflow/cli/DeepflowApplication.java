package com.bering.deepflow.cli;

import com.bering.deepflow.dataParsing.CSVParser;
import com.bering.deepflow.neuralNetworks.DeepAutoencoder;

import java.nio.file.Paths;

/**
 * Created by benjamin on 23/03/17.
 *
 * The entry point to the program. Takes 3 arguments:
 * 1) The data-set file to process
 * 2) The number of lines to skip in this file to reach the first row of data
 * 3) (Optional) A list of features for the data-set, those not present will be filtered out
 */
public class DeepflowApplication {

    public static void main(String[] args){
        String pwd = Paths.get(".").toAbsolutePath().normalize().toString();
        System.out.println(pwd);
        String inputFile = args[0];
        String filepath = pwd + "/" + inputFile;
        System.out.println("filepath: " + filepath);
        int linesToSkip = Integer.parseInt(args[1]);

        if (args.length > 2 ) {
            String featureFilePath = args[2];
            CSVParser parser = new CSVParser(filepath, linesToSkip, featureFilePath);
        } else {
            CSVParser parser = new CSVParser(filepath, linesToSkip);
        }

        DeepAutoencoder autoencoder = new DeepAutoencoder(inputFile+"_processed");

    }

}
