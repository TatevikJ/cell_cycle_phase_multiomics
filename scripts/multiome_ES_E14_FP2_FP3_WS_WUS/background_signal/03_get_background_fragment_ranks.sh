#!/bin/bash
# This script runs bedtools intersect command on given bed (or bed-like) files
# with -wo option to write the original A and B entries plus the number of base pairs of overlap between the two features.
# 1st argument - background fragments .bed file
# 2nd argument - replication ranks per bin .tsv file
# 3rd argument - output/path.bed

# Note: run after notebooks/replication_timing/02_get_replication_ranks_per_bin.ipynb

FILE1=$1
FILE2=$2
OUT_PATH=$3


# load modules
#module load BEDTools/2.30.0-GCC-12.2.0


bedtools intersect -wo \
    -a ${FILE1} \
    -b ${FILE2} \
    > ${OUT_PATH}

