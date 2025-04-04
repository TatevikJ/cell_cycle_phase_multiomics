#!/bin/bash
#SBATCH --mem-per-cpu=15G
#SBATCH -c 4
#SBATCH -p long
#SBATCH --output=log/FL_cellranger_count_antibody_capture-slurm-%j.out   # %j will be replaced with the Job ID


# Script amended from /gpfs3/well/beagrie/users/son496/multiome

#-----------------------LOAD REQUIRED MODULES-----------------------
module load CellRanger/8.0.1

#-----------------------------RUN SCRIPT----------------------------

cellranger count \
	   --id=FL \
	   --transcriptome=/well/beagrie/shared/genomes/Mus-musculus/mm10/refdata-gex-mm10-2020-A \
	   --libraries=/well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out_FL_TEA/multiome/cellranger_antibody_capture/FL_libraries.csv \
	   --feature-ref=/well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out_FL_TEA/multiome/cellranger_antibody_capture/FL_feature_ref.csv \
	   --chemistry=ARC-v1 \
	   --create-bam=true \
	   --localcores=4 \
	   --localmem=60
