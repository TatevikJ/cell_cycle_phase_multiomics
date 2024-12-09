#!/bin/bash
#SBATCH --mem-per-cpu=15G
#SBATCH -c 4
#SBATCH --time=3-00:00:00
#SBATCH -p long


# This script 
#        first runs bedtools intersect command on given bed (or bed-like) file to intersect it with itself
#        then filters the output with awk to ensure that:
#		  The chromosome from file A matches the chromosome from file B.
#		  Either the start positions are different or the end positions are different to avoid self-overlaps.
#		  The cell identifiers match.
#		  Only one row per overlap is kept by enforcing that the start position from file A is less than the start position from file B.

# 1st argument - fragments .bed file
# 2nd argument - output/path.bed 

FILE=$1
OUT_DIR=$2


#-----------------------LOAD REQUIRED MODULES-----------------------
module load BEDTools/2.30.0-GCC-12.2.0

#-----------------------------RUN SCRIPT----------------------------
bedtools intersect \
    -a ${FILE} \
    -b ${FILE} \
    -wo | \
    awk '$1 == $6 && ($2 != $7 || $3 != $8) && $4 == $9  && $2 < $7' - \
    > ${OUT_DIR}/atac_overlapping_fragments.bed


