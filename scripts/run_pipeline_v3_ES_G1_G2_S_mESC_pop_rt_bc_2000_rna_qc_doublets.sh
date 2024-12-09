#!/bin/bash
#SBATCH --mem-per-cpu=40G
#SBATCH -c 4
#SBATCH -p long
#SBATCH --output=log/run_pipeline_v3_ES_G1_G2_S_mESC_pop_rt_bc_2000_rna_qc_doublets-slurm-%j.out


bash scripts/pipeline_v3.sh \
     "out_ES_G1_G2_S/pipeline_v3_out/out_ES_G1_G2_S_mESC_pop_rt_bc_2000_rna_qc_doublets.csv" \
     "data/mm10_all_genes/mm10_genes_ucsc.bed" \
     "data/external/GSE102077/GSE102076_Population_repli-seq.txt.gz" \
     "out_ES_G1_G2_S/pipeline_v3_out/out_ES_G1_G2_S_mESC_pop_rt_bc_2000_rna_qc_doublets"

