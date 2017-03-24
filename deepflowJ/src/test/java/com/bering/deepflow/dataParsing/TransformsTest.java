package com.bering.deepflow.dataParsing;

import org.datavec.api.util.ClassPathResource;
import org.junit.Test;
import org.nd4j.linalg.api.ndarray.INDArray;
import org.nd4j.linalg.dataset.DataSet;
import java.io.FileNotFoundException;


import static org.junit.Assert.assertEquals;

/**
 * Created by benjamin on 14/03/17.
 */
public class TransformsTest {

    @Test
    public void testApplyFeatureMask() {

        boolean[] mask = new boolean[]{false, false, false, false, true};
        String[] features = new String[]{"feature", "feature", "feature", "feature", "feature"};

        String[] filteredFeatures = Transforms.applyFeatureMask(mask, features);
        assertEquals(1, filteredFeatures.length);
        assertEquals("feature", filteredFeatures[0]);
    }

    @Test
    public void testApplyMask() {

        // Generate mask.
        boolean[] mask = new boolean[45];
        for (int i=0; i<4; i++) mask[i] = false;
        for (int i=4; i<mask.length; i++) mask[i] = true;

        DataSet dataSet = new DataSet();
        try {
            dataSet.load(new ClassPathResource("c11_S001visit1_CD8+ cells.fcs_raw_events_processed").getFile());
        }
        catch (FileNotFoundException e) {
            System.out.println("Could not load test data.");
            return;
        }

        DataSet filteredDataSet = Transforms.applyMask(mask, dataSet);
        assertEquals(41, dataSet.getFeatures().columns());
    }

    @Test
    public void testArcSinh() {
        DataSet dataSet = new DataSet();
        try {
            dataSet.load(new ClassPathResource("c11_S001visit1_CD8+ cells.fcs_raw_events_truncated").getFile());
        }
        catch (FileNotFoundException e) {
            System.out.println("Could not load test data.");
            return;
        }

        double[] validData = new double[] {
                0.00, 0.00, 0.00, 0.00, 0.51, 0.00, 0.81, 0.00, 0.00, 3.73, 0.41, 0.86, 1.07, 0.00, 0.00, 4.76, 3.74, 0.00, 2.67, 3.25, 0.07, 0.14, 0.57, 2.68, 0.59, 0.00, 0.79, 1.64, 5.69, 1.57, 6.18, 2.04, 0.00, 0.00, 0.00, 0.00, 0.00, 5.11, 5.88, 0.00, 4.45, 4.16, 4.83, 0.00, 1.38
        };

        DataSet transformedDataSet = Transforms.arcsinh(dataSet, 5);
        INDArray array = transformedDataSet.getFeatures();

        for (int i=0; i<validData.length; i++){
            double element = array.getDouble(i);
            assertEquals(validData[i], element, 0.1);
        }
    }
}
