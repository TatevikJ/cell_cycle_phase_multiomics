#!/bin/bash
# This script runs bedtools makewindows command on given chromosome sizes file
# 1st argument - fixed window size of each interval
# 2nd argument - folder in which output should be written
# Example: path_to_this_script.sh 100000 /output/folder

WINDOW_SIZE=$1
OUT_DIR=$2

#Note: change bedtools path
/apps/eb/2020b/skylake/software/BEDTools/2.30.0-GCC-11.2.0/bin/bedtools makewindows \
    -g /well/beagrie/shared/genomes/Mus-musculus/mm39/chrom.sizes \
    -w ${WINDOW_SIZE} \
    > ${OUT_DIR}/mm39_${WINDOW_SIZE}_windows.bed
