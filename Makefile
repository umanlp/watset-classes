all:

dt-59g-deps-wpf1k-fpw1k.csv.gz:
	curl -sLO "http://panchenko.me/data/joint/dt/$@"

super-senses-wordnet.tsv:
	curl -sLO "http://panchenko.me/data/joint/$@"
