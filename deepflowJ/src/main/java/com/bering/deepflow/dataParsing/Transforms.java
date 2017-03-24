package com.bering.deepflow.dataParsing;

import org.nd4j.linalg.api.ndarray.INDArray;
import org.nd4j.linalg.cpu.nativecpu.NDArray;
import org.nd4j.linalg.dataset.DataSet;
import org.nd4j.linalg.util.BigDecimalMath;

import java.math.BigDecimal;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

/**
 * Created by benjamin on 14/03/17.
 */
class Transforms {

    static DataSet arcsinh(DataSet dataSet, int covariant) {

        dataSet.divideBy(covariant);

        ExecutorService es = Executors.newCachedThreadPool();

        class BatchAsinhTransform implements Runnable {
            private INDArray array;
            private int index;
            private int batchSize;

            private BatchAsinhTransform(INDArray array, int index, int batchSize) {
                this.array = array;
                this.index = index;
                this.batchSize = batchSize;
            }

            public void run() {
                while (index < array.length()) {
                    double element = array.getDouble(index);
                    BigDecimal bigDecimal = BigDecimal.valueOf(element);
                    bigDecimal = BigDecimalMath.asinh(bigDecimal);
                    element = bigDecimal.doubleValue();
                    array.putScalar(index, element);
                    index += batchSize;
                }
            }
        }

        INDArray indArrays = dataSet.getFeatures();
        int batchSize = 4;

        for (int i=0; i<batchSize; i++ ){
            es.execute(new BatchAsinhTransform(indArrays, i, batchSize));
        }

        es.shutdown();
        try {
            boolean finished = es.awaitTermination(1, TimeUnit.HOURS);
        }
        catch (InterruptedException e) {
            System.out.println(e.getMessage());
        }

        return dataSet;
    }

    static DataSet applyMask(boolean[] mask, DataSet dataSet) {

        int numToRemove = countNumToRemove(mask);

        INDArray inputArray = dataSet.getFeatures();
        INDArray filteredArray = new NDArray(new int[]{inputArray.rows(), inputArray.columns() - numToRemove});
        int filteredArrayIndex = 0;

        for (int i = 0; i < inputArray.columns(); i++) {
            if (mask[i] == true) {
                filteredArray.putColumn(filteredArrayIndex, inputArray.getColumn(i));
                filteredArrayIndex += 1;
            }
        }

        dataSet.setFeatures(filteredArray);

        return dataSet;
    }

    static String[] applyFeatureMask(boolean[] mask, String[] features) {
        int numToRemove = countNumToRemove(mask);
        String[] filteredFeatures = new String[features.length - numToRemove];
        int filteredFeaturesIndex = 0;

        for (int i=0; i<features.length; i++) {
            if (mask[i] == true) {
                filteredFeatures[filteredFeaturesIndex] = features[i];
                filteredFeaturesIndex += 1;
            }
        }

        return filteredFeatures;
    }

    private static int countNumToRemove(boolean[] mask) {
        int count = 0;
        for (boolean bool: mask) {
            if (bool == false) {
                count += 1;
            }
        }
        return count;
    }



}
