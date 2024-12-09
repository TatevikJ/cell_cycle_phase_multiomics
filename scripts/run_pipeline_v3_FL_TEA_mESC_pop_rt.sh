#!/bin/bash
#SBATCH --mem-per-cpu=40G
#SBATCH -c 4
#SBATCH -p long
#SBATCH --output=log/run_pipeline_v3_FL_TEA_mESC_pop_rt-slurm-%j.out


bash scripts/pipeline_v3.sh \
     "out_FL_TEA/pipeline_v3_out/out_FL_TEA_mESC_pop_rt.csv" \
     "data/mm10_all_genes/mm10_genes_ucsc.bed" \
     "data/external/GSE102077/GSE102076_Population_repli-seq.txt.gz" \
     "out_FL_TEA/pipeline_v3_out/out_FL_TEA_mESC_pop_rt"

