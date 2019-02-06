#!/usr/bin/env groovy
import org.nlpub.watset.eval.CachedNormalizedModifiedPurity
import org.nlpub.watset.eval.NormalizedModifiedPurity
import org.nlpub.watset.util.Sampling

import java.nio.file.Files
import java.nio.file.Paths

import static NormalizedModifiedPurity.normalize
import static NormalizedModifiedPurity.transform

Locale.setDefault(Locale.ROOT)

/*
 * Usage: groovy -classpath ../watset-java/target/watset.jar dt.tsv gold-super-senses.tsv
 */
def options = new CliBuilder().with {
    usage = 'supersenses_nmpu.groovy dt.tsv gold-super-senses.tsv'

    t 'tabular format'
    p 'percentage format'
    s args: 1, 'sampling file'

    parse(args) ?: System.exit(1)
}

actual = new ArrayList<List<String>>()

Files.newInputStream(Paths.get(options.arguments()[0])).eachLine { line ->
    (id, count, lemmasSerialized) = line.split('\t', 3)

    lemmas = lemmasSerialized.split(', ').toList()
    assert lemmas.size() == Integer.valueOf(count)

    actual.add(lemmas)
}

expected = new HashMap<String, Set<String>>()

Files.newInputStream(Paths.get(options.arguments()[1])).eachLine { line ->
    (klass, sense) = line.split('\t', 2)

    if (!expected.containsKey(klass)) {
        expected.put(klass, new HashSet<>())
    }

    (lemma, pos, _) = sense.split('\\.', 3)

    if (pos == 'n') expected.get(klass).add(lemma)
}

format = options.p ? '%.2f\t%.2f\t%.2f' : '%.5f\t%.5f\t%.5f'

actual = transform(actual)
expected = normalize(transform(expected.values().findAll().toList()))

purity_pr = new CachedNormalizedModifiedPurity<String>()
purity_re = new NormalizedModifiedPurity<String>(true, false)
result = NormalizedModifiedPurity.evaluate(purity_pr, purity_re, normalize(actual), expected)

pr = result.precision * (options.p ? 100 : 1)
re = result.recall * (options.p ? 100 : 1)
f1 = result.f1Score * (options.p ? 100 : 1)

if (options.t) {
    printf(format + '\t', pr, re, f1)
} else {
    printf('Super Sense nmPU/niPU/F1: ' + format + '%n', pr, re, f1)
}

if (options.s) {
    random = new Random(1337)

    dataset = actual.toArray(new Map<String, Double>[0])
    f1_samples = new double[500]

    System.err.print('Bootstrapping')

    for (i = 0; i < f1_samples.length; i++) {
        sample = normalize(Sampling.sample(dataset, random))
        result = NormalizedModifiedPurity.evaluate(purity_pr, purity_re, sample, expected)
        f1_samples[i] = result.f1Score
        System.err.printf(' %d', i + 1)
        System.err.flush()
    }

    System.err.println()

    Files.newOutputStream(Paths.get(options.s)).withCloseable { fos ->
        new ObjectOutputStream(fos).withCloseable { oos ->
            oos.writeObject(f1_samples)
        }
    }
}
