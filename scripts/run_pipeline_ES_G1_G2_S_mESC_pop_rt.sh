#!/bin/bash
#SBATCH --mem-per-cpu=40G
#SBATCH -c 4
#SBATCH -p long
#SBATCH --output=log/run_pipeline_ES_G1_G2_S_mESC_pop_rt-slurm-%j.out   # %j will be replaced with the Job ID


bash scripts/pipeline.sh \
     "/well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out_ES_G1_G2_S/multiome/cellranger" \
     "G1 G2 S" \
     "/well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/data/mm10_all_genes/mm10_genes_ucsc.bed" \
     "/well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/data/external/GSE102077/GSE102076_Population_repli-seq.txt.gz" \
     "out_ES_G1_G2_S/pipeline_out/out_ES_G1_G2_S_mESC_pop_rt"

