#!/bin/bash
#SBATCH --mem-per-cpu=15G
#SBATCH -c 8
#SBATCH -p long
#SBATCH --output=log/run_pipeline_v3_ES_G1_G2_S_mESC_pop_rt_downsampled_20000-slurm-%j.out

# use peak list from full dataset and barcodes that passed the filtering on the full dataset

bash scripts/pipeline_v3.sh \
     "out_ES_G1_G2_S/pipeline_v3_out/out_ES_G1_G2_S_mESC_pop_rt_downsampled_20000.csv" \
     "data/mm10_all_genes/mm10_genes_ucsc.bed" \
     "data/external/GSE102077/GSE102076_Population_repli-seq.txt.gz" \
     "out_ES_G1_G2_S/pipeline_v3_out/out_ES_G1_G2_S_mESC_pop_rt_downsampled_20000"

