#!/bin/bash
#!/bin/bash
#SBATCH --mem-per-cpu=15G
#SBATCH -c 4
#SBATCH --time=3-00:00:00
#SBATCH -p long
#SBATCH --output=log/G2_cellranger_count-slurm-%j.out   # %j will be replaced with the Job ID

# Script amended from /gpfs3/well/beagrie/users/son496/multiome

#-----------------------LOAD REQUIRED MODULES-----------------------
module load CellRanger-ARC/2.0.2

#-----------------------------RUN SCRIPT----------------------------

cellranger-arc count \
    --id=G2 \
    --reference=/well/beagrie/shared/genomes/Mus-musculus/mm10/refdata-cellranger-arc-mm10-2020-A-2.0.0 \
    --libraries=/well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out_ES_G1_G2_S/multiome/cellranger/G2_libraries.csv \
    --localcores=4 \
    --localmem=60
