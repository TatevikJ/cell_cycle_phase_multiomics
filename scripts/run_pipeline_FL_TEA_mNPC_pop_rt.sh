#!/bin/bash
#SBATCH --mem-per-cpu=40G
#SBATCH -c 4
#SBATCH -p long
#SBATCH --output=log/run_pipeline_FL_TEA_mNPC_pop_rt-slurm-%j.out   # %j will be replaced with the Job ID


bash scripts/pipeline.sh \
     "/well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out_FL_TEA/multiome/cellranger" \
     "FL" \
     "/well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/data/mm10_all_genes/mm10_genes_ucsc.bed" \
     "/well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/data/external/GSE137764/GSE137764_mNPC_Gaussiansmooth_scaled_autosome_rt_value.tsv" \
     "out_FL_TEA/pipeline_out/out_FL_TEA_mNPC_pop_rt"

