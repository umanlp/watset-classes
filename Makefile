all:

dt-59g-deps-wpf1k-fpw1k.csv.gz:
	curl -sLO "http://panchenko.me/data/joint/dt/$@"

super-senses-wordnet.tsv:
	curl -sLO "http://panchenko.me/data/joint/semantic-classes/$@"

wordnet-flat-cut-depth-4-clusters-2017-minclusize-2.tsv:
	curl -sLO "http://panchenko.me/data/joint/semantic-classes/$@"

wordnet-flat-cut-depth-5-clusters-5737-minclusize-2.tsv:
	curl -sLO "http://panchenko.me/data/joint/semantic-classes/$@"

wordnet-flat-cut-depth-6-clusters-11274-minclusize-2.tsv:
	curl -sLO "http://panchenko.me/data/joint/semantic-classes/$@"

watset.jar:
	curl -sLO "https://github.com/nlpub/watset-java/releases/download/2.0.0-beta13/$@"
