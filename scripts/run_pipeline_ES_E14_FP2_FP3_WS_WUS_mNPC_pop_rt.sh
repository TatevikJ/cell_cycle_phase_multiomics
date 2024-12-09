#!/bin/bash
#SBATCH --mem-per-cpu=30G
#SBATCH -c 4
#SBATCH --time=3-00:00:00
#SBATCH -p long
#SBATCH --output=log/run_pipeline_ES_E14_FP2_FP3_WS_WUS_mNPC_pop_rt-slurm-%j.out   # %j will be replaced with the Job ID


bash scripts/pipeline.sh \
     "/well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/cellranger" \
     "ES_E14_sorted ES_E14_unsorted FucciCA2_E14_sorted_P3 FucciCA2_E14_sorted_allpop" \
     "/well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/data/mm10_all_genes/mm10_genes_ucsc.bed" \
     "/well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/data/external/GSE137764/GSE137764_mNPC_Gaussiansmooth_scaled_autosome_rt_value.tsv" \
     "out/pipeline_out/out_ES_E14_FP2_FP3_WS_WUS_mNPC_pop_rt"

