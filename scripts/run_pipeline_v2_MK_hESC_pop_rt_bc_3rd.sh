#!/bin/bash
#SBATCH --mem-per-cpu=40G
#SBATCH -c 4
#SBATCH -p long
#SBATCH --output=log/run_pipeline_v2_MK_hESC_pop_rt_bc_3rd-slurm-%j.out


bash scripts/pipeline_v2.sh \
     "out_MK/pipeline_v2_out/out_MK_hESC_pop_rt_bc_3rd.csv" \
     "data/hg38_all_genes/hg38_genes_ucsc.bed" \
     "data/external/GSE137764/GSE137764_H1_GaussiansGSE137764_mooth_scaled_autosome_rt_value.tsv" \
     "out_MK/pipeline_v2_out/out_MK_hESC_pop_rt_bc_3rd"

