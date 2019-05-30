# Unsupervised Distributional Semantic Class Induction with Watset

This repository contains code for running semantic class induction with [Watset](https://github.com/nlpub/watset-java). Since this experiment mostly re-uses the already written code for other experiments, it contains convenient wrappers for the corresponding tools.

## Dataset Download

```shell
$ make dt-59g-deps-wpf1k-fpw1k.csv.gz # distributional thesaurus (DT)
$ gunzip dt-59g-deps-wpf1k-fpw1k.csv.gz
```

```shell
$ make super-senses-wordnet.tsv # WordNet super senses dataset
$ make wordnet-flat-cut-depth-4-clusters-2017-minclusize-2.tsv # WordNet slices, d=4
$ make wordnet-flat-cut-depth-5-clusters-5737-minclusize-2.tsv # WordNet slices, d=5
$ make wordnet-flat-cut-depth-6-clusters-11274-minclusize-2.tsv # WordNet slices, d=6
$ make watset.jar # Watset
```

## Dataset Pruning

The original distributional thesaurus (`dt-59g-deps-wpf1k-fpw1k.csv.gz`) is large, so we used a pruned version of this dataset.

```shell
$ ./dt-wordnet.py -t 0.001 -w super-senses-wordnet.tsv dt-59g-deps-wpf1k-fpw1k.csv -o dt-wordnet-0_001.txt
$ ./dt-wordnet.py -t 0.01 -w super-senses-wordnet.tsv dt-59g-deps-wpf1k-fpw1k.csv -o dt-wordnet-0_01.txt
```

This is performed similarly for the WordNet slices, e.g., for `d=4`.

```shell
$ ./dt-wordnet.py -t 0.001 -w wordnet-flat-cut-depth-4-clusters-2017-minclusize-2.tsv dt-59g-deps-wpf1k-fpw1k.csv -o dt-wordnet-d4-0_001.txt
$ ./dt-wordnet.py -t 0.01 -w wordnet-flat-cut-depth-4-clusters-2017-minclusize-2.tsv dt-59g-deps-wpf1k-fpw1k.csv -o dt-wordnet-d4-0_01.txt
```

## Running

Make sure that all the variables in `evaluate.sh` are specified correctly. This script runs everything, including running the clustering algorithms and evaluating them. Note that the `-s` flag of `supersenses_nmpu.groovy` performs sampling, which is *extremely* slow. However, it can be disabled, which is the recommended behaviour during prototyping.

The results of the sampling can be checked with t-test using `sampled_ttest.groovy`. The output format is tab-separated: `file1`,`file2`,`mean1`,`mean2`,`var1`,`var2`,`pvalue`.

```shell
$ ./sampled_ttest.groovy eval/dt-wordnet-0_01-*.ser
```
