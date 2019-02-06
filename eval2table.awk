#!/usr/bin/gawk -f

BEGIN {
    OFS = ";"
}

/^#/ {
    DATASET = $2
}

/^Super Sense/ {
    print DATASET, $4, $5, $6
}
