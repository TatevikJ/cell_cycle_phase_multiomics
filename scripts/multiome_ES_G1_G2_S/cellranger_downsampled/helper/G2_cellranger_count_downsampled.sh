#!/bin/bash
#SBATCH --mem-per-cpu=5G
#SBATCH -c 8
#SBATCH --time=3-00:00:00
#SBATCH -p long
#SBATCH --output=log/G2_cellranger_count_downsampled-slurm-%j.out   # %j will be replaced with the Job ID


# Script amended from /gpfs3/well/beagrie/users/son496/multiome

#-----------------------LOAD REQUIRED MODULES-----------------------
module load CellRanger-ARC/2.0.2

#-----------------------------RUN SCRIPT----------------------------
n=$1
CURRENT_DIR=$(pwd)

#for n in 5000 10000 12500 15000 17500 20000; do
echo -e "\nRunning cellranger on random sample of ${n}*n_cells read pairs...\n"

mkdir -p out_ES_G1_G2_S/multiome/cellranger_downsampled/ATAC_downsampled_${n}
cd out_ES_G1_G2_S/multiome/cellranger_downsampled/ATAC_downsampled_${n}

cellranger-arc count \
	       --id=G2 \
	       --reference=/well/beagrie/shared/genomes/Mus-musculus/mm10/refdata-cellranger-arc-mm10-2020-A-2.0.0 \
	       --libraries=/well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out_ES_G1_G2_S/multiome/cellranger_downsampled/G2_${n}_libraries.csv \
	       --localcores=8 \
	       --localmem=40
#done

echo -e "\nDONE: cellranger on random sample of ${n}*n_cells read pairs...\n"

cd "$CURRENT_DIR"
