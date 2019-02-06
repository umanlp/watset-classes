#!/bin/bash -ex

# ./dt-wordnet.py -t 0.1 -w super-senses-wordnet.tsv dt-59g-deps-wpf1k-fpw1k.csv -o dt-wordnet-0_1.txt

export LANG=en_US.UTF-8 LC_COLLATE=C
export JAVA_OPTS="$JAVA_OPTS -Xms64G -Xmx512G"

WATSET="$WORK/watset-java/target/watset.jar"
MCL="$WORK/mcl-14-137/bin/mcl"
NMPU="$WORK/watset-classes/supersenses_nmpu.groovy"
GOLD=super-senses-wordnet.tsv
# GOLD=wordnet-flat-cut-depth-4-clusters-2017-minclusize-2.tsv
# GOLD=wordnet-flat-cut-depth-5-clusters-5737-minclusize-2.tsv
# GOLD=wordnet-flat-cut-depth-6-clusters-11274-minclusize-2.tsv

#rm -rf eval
mkdir -p eval

# for DT in dt-wordnet-0_1.txt dt-wordnet-0_01.txt dt-wordnet-0_001.txt ; do
# for DT in dt-wordnet-d4-0_1.txt dt-wordnet-d4-0_01.txt dt-wordnet-d4-0_001.txt ; do
# for DT in dt-wordnet-d5-0_1.txt dt-wordnet-d5-0_01.txt dt-wordnet-d5-0_001.txt ; do
# for DT in dt-wordnet-d6-0_1.txt dt-wordnet-d6-0_01.txt dt-wordnet-d6-0_001.txt ; do
# for DT in dt-wordnet-0_1.txt dt-wordnet-0_01.txt ; do
for DT in dt-wordnet-0_001.txt ; do
    DT_OUTPUT="eval/${DT%.txt}"

    if false ; then

    for CW in top log nolog ; do
       time nice java -jar "$WATSET" -i "$DT" -o "$DT_OUTPUT-cw-$CW.tsv" cw -m "$CW"
    done

    time nice java -jar "$WATSET" -i "$DT" -o "$DT_OUTPUT-mcl.tsv" mcl-bin --bin "$MCL"

    for CW_LOCAL in top log nolog ; do
        for CW_GLOBAL in top ; do
            time nice java -jar "$WATSET" -i "$DT" -o "$DT_OUTPUT-watset-cw-$CW_LOCAL-cw-$CW_GLOBAL.tsv" watset -l cw -lp "mode=$CW_LOCAL" -g cw -gp "mode=$CW_GLOBAL"
        done

        time nice java -jar "$WATSET" -i "$DT" -o "$DT_OUTPUT-watset-cw-$CW_LOCAL-mcl.tsv" watset -l cw -lp "mode=$CW_LOCAL" -g mcl-bin -gp "bin=$MCL"
    done

    # for CW_GLOBAL in top log nolog ; do
    #     time nice java -jar "$WATSET" -i "$DT" -o "$DT_OUTPUT-watset-mcl-cw-$CW_GLOBAL.tsv" watset -l mcl -g cw -gp "mode=$CW_GLOBAL"
    # done

    # time nice java -jar "$WATSET" -i "$DT" -o "$DT_OUTPUT-watset-mcl-mcl.tsv" watset -l mcl -g mcl-bin -gp "bin=$MCL"

    fi

    DT_REPORT="${DT%.txt}-eval.txt"
    echo -n > "$DT_REPORT"

    RESULTS=$(find eval -maxdepth 1 -type f -wholename "$DT_OUTPUT-*.tsv")

    for CLUSTERS in $RESULTS ; do
        DT_SAMPLES="${CLUSTERS%.tsv}.ser"

        echo "# $CLUSTERS" >> "$DT_REPORT"
        time nice groovy -classpath "$WATSET" "$NMPU" -s "$DT_SAMPLES" -p "$CLUSTERS" "$GOLD" | tee -a "$DT_REPORT"
        # time nice groovy -classpath "$WATSET" "$NMPU" -p "$CLUSTERS" "$GOLD" | tee -a "$DT_REPORT"
        echo >> "$DT_REPORT"
    done
done
