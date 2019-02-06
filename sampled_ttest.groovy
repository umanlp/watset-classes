#!/usr/bin/env groovy

@Grab(group = 'org.apache.commons', module = 'commons-math3', version = '3.6.1')
import org.apache.commons.math3.stat.inference.TTest
import org.apache.commons.math3.stat.StatUtils

import java.nio.file.Files
import java.nio.file.Paths

Locale.setDefault(Locale.ROOT)

/*
 * Usage: groovy sampled_ttest.groovy model1.ser model2.ser ...
 */
def options = new CliBuilder().with {
    usage = 'sampled_ttest.groovy model1.ser model2.ser ...'

    parse(args) ?: System.exit(1)
}

datasets = options.arguments().unique().collectEntries { filename ->
    Files.newInputStream(Paths.get(filename)).withCloseable { fis ->
        new ObjectInputStream(fis).withCloseable { ois ->
            sample = (double[]) ois.readObject()
        }
    }

    System.err.printf('%s contains %d observations%n', filename, sample.length)

    [(filename): sample]
}

cases = [datasets.keySet(), datasets.keySet()].combinations().findAll { a, b -> a < b }

test = new TTest()

cases.each { pair ->
    (filename1, filename2) = pair

    sample1 = datasets.get(filename1)
    sample2 = datasets.get(filename2)

    pvalue = test.tTest(sample1, sample2)

    printf('%s\t%s\t%f±%f\t%f±%f\t%f\n',
            filename1, filename2,
            StatUtils.mean(sample1), StatUtils.variance(sample1),
            StatUtils.mean(sample2), StatUtils.variance(sample2),
            pvalue)
}
