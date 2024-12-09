#!/bin/bash
#SBATCH --mem-per-cpu=15G
#SBATCH -c 4
#SBATCH -p long
#SBATCH --output=log/FL_cellranger_count-slurm-%j.out   # %j will be replaced with the Job ID


# Script amended from /gpfs3/well/beagrie/users/son496/multiome

#-----------------------LOAD REQUIRED MODULES-----------------------
module load CellRanger-ARC/2.0.2

#-----------------------------RUN SCRIPT----------------------------

cellranger-arc count \
    --id=FL \
    --reference=/well/beagrie/shared/genomes/Mus-musculus/mm10/refdata-cellranger-arc-mm10-2020-A-2.0.0 \
    --libraries=/well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out_FL_TEA/multiome/cellranger/FL_libraries.csv \
    --localcores=4 \
    --localmem=60
