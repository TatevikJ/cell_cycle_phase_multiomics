#!/bin/bash
# This script runs bedtools intersect command on given bed (or bed-like) files
# with -v option to only report those entries in A that have no overlap in B
# 1st argument - fragments .tsv.gz file
# 2nd argument - peaks .bed file
# Example: path_to_this_script.sh /path/to/fragments.tsv.gz /path/to/peaks.bed /output/folder

FILE1=$1
FILE2=$2
OUT_DIR=$3

# load module
#module load BEDTools/2.30.0-GCC-12.2.0

#Note: load bedtools module first
bedtools intersect -v \
    -a ${FILE1} \
    -b ${FILE2} \
    > ${OUT_DIR}/atac_background_fragments.bed


#Run
#get_background_fragments.sh /well/beagrie/users/son496/multiome/cellranger/MULTIOME/FucciCA2_E14_sorted_allpop/outs/atac_fragments.tsv.gz /well/beagrie/users/son496/multiome/cellranger/MULTIOME/FucciCA2_E14_sorted_allpop/outs/atac_peaks.bed out/multiome/FucciCA2_E14_sorted_allpop
