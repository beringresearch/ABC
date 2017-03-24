package com.bering.deepflow.cli;

import java.nio.file.Paths;
import com.bering.deepflow.dataParsing.CSVParser;
import com.bering.deepflow.neuralNetworks.DeepAutoencoder;
import com.bering.deepflow.neuralNetworks.StackedDenoisingAutoencoder;

/**
 * Created by benjamin on 23/03/17.
 */
public class DeepflowApplication {

    public static void main(String[] args){
        /*String pwd = Paths.get(".").toAbsolutePath().normalize().toString();
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
        }*/

        DeepAutoencoder autoencoder = new DeepAutoencoder();
        //StackedDenoisingAutoencoder autoencoder = new StackedDenoisingAutoencoder();

    }

}
