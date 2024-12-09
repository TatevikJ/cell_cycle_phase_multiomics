#!/bin/bash
#SBATCH --mem-per-cpu=15G
#SBATCH -c 4
#SBATCH --time=3-00:00:00
#SBATCH -p long

# Script amended from /gpfs3/well/beagrie/users/son496/multiome

#-----------------------LOAD REQUIRED MODULES-----------------------
module load CellRanger-ARC/2.0.0

#-----------------------------RUN SCRIPT----------------------------

cellranger-arc count \
    --id=FucciCA2_E14_sorted_allpop \
    --reference=/well/beagrie/shared/genomes/Mus-musculus/mm10/refdata-cellranger-arc-mm10-2020-A-2.0.0 \
    --libraries=/well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/cellranger/FP2_libraries.csv \
    --localcores=4 \
    --localmem=60
