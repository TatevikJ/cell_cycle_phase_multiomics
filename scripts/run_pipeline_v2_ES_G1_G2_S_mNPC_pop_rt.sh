#!/bin/bash
#SBATCH --mem-per-cpu=40G
#SBATCH -c 4
#SBATCH -p long
#SBATCH --output=log/run_pipeline_v2_ES_G1_G2_S_mNPC_pop_rt_bc_2000-slurm-%j.out


bash scripts/pipeline_v2.sh \
     "out_ES_G1_G2_S/pipeline_v2_out/out_ES_G1_G2_S_mNPC_pop_rt_bc_2000.csv" \
     "data/mm10_all_genes/mm10_genes_ucsc.bed" \
     "data/external/GSE137764/GSE137764_mNPC_Gaussiansmooth_scaled_autosome_rt_value.tsv" \
     "out_ES_G1_G2_S/pipeline_v2_out/out_ES_G1_G2_S_mNPC_pop_rt_bc_2000"

