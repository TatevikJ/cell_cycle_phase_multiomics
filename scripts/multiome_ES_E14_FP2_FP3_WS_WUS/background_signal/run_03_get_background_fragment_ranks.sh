#!/bin/bash
# This scripts calls 03_get_background_fragment_ranks.sh with different input parameters

### FucciCA2_E14_sorted_allpop ###
echo "Running on FucciCA2_E14_sorted_allpop"
echo "Running on population data ranks"
#bash scripts/multiome/background_signal/03_get_background_fragment_ranks.sh \
#    out/multiome/background_signal/FucciCA2_E14_sorted_allpop/atac_background_fragments.bed \
#    out/external/replication_timing/GSE102077/GSE102076_Population_repli-seq_ranks.tsv \
#    out/multiome/background_signal/FucciCA2_E14_sorted_allpop/atac_background_fragments_population_ranks.bed


echo "Running on single cell data ranks"
#bash scripts/multiome/background_signal/03_get_background_fragment_ranks.sh \
#    out/multiome/background_signal/FucciCA2_E14_sorted_allpop/atac_background_fragments.bed \
#    out/external/replication_timing/GSE102077/GSE102074_singlecell_binarized_ranks.tsv \
#    out/multiome/background_signal/FucciCA2_E14_sorted_allpop/atac_background_fragments_singlecell_ranks.bed


echo "Running on single cell data ranks without na filtering"
#bash scripts/multiome/background_signal/03_get_background_fragment_ranks.sh \
#    out/multiome/background_signal/FucciCA2_E14_sorted_allpop/atac_background_fragments.bed \
#    out/external/replication_timing/GSE102077/GSE102074_singlecell_binarized_ranks_with_na.tsv \
#    out/multiome/background_signal/FucciCA2_E14_sorted_allpop/atac_background_fragments_singlecell_ranks_with_na.bed
##################################

### ES_E14_sorted ###
echo "Running on ES_E14_sorted"
echo "Running on population data ranks"
bash scripts/multiome/background_signal/03_get_background_fragment_ranks.sh \
    out/multiome/background_signal/ES_E14_sorted/atac_background_fragments.bed \
    out/external/replication_timing/GSE102077/GSE102076_Population_repli-seq_ranks.tsv \
    out/multiome/background_signal/ES_E14_sorted/atac_background_fragments_population_ranks.bed


echo "Running on single cell data ranks"
bash scripts/multiome/background_signal/03_get_background_fragment_ranks.sh \
    out/multiome/background_signal/ES_E14_sorted/atac_background_fragments.bed \
    out/external/replication_timing/GSE102077/GSE102074_singlecell_binarized_ranks.tsv \
    out/multiome/background_signal/ES_E14_sorted/atac_background_fragments_singlecell_ranks.bed


echo "Running on single cell data ranks without na filtering"
bash scripts/multiome/background_signal/03_get_background_fragment_ranks.sh \
    out/multiome/background_signal/ES_E14_sorted/atac_background_fragments.bed \
    out/external/replication_timing/GSE102077/GSE102074_singlecell_binarized_ranks_with_na.tsv \
    out/multiome/background_signal/ES_E14_sorted/atac_background_fragments_singlecell_ranks_with_na.bed
##################################

### ES_E14_unsorted ###
echo "Running on ES_E14_unsorted"
echo "Running on population data ranks"
bash scripts/multiome/background_signal/03_get_background_fragment_ranks.sh \
    out/multiome/background_signal/ES_E14_unsorted/atac_background_fragments.bed \
    out/external/replication_timing/GSE102077/GSE102076_Population_repli-seq_ranks.tsv \
    out/multiome/background_signal/ES_E14_unsorted/atac_background_fragments_population_ranks.bed


echo "Running on single cell data ranks"
bash scripts/multiome/background_signal/03_get_background_fragment_ranks.sh \
    out/multiome/background_signal/ES_E14_unsorted/atac_background_fragments.bed \
    out/external/replication_timing/GSE102077/GSE102074_singlecell_binarized_ranks.tsv \
    out/multiome/background_signal/ES_E14_unsorted/atac_background_fragments_singlecell_ranks.bed


echo "Running on single cell data ranks without na filtering"
bash scripts/multiome/background_signal/03_get_background_fragment_ranks.sh \
    out/multiome/background_signal/ES_E14_unsorted/atac_background_fragments.bed \
    out/external/replication_timing/GSE102077/GSE102074_singlecell_binarized_ranks_with_na.tsv \
    out/multiome/background_signal/ES_E14_unsorted/atac_background_fragments_singlecell_ranks_with_na.bed
##################################

### FucciCA2_E14_sorted_P3 ###
echo "Running on FucciCA2_E14_sorted_P3"
echo "Running on population data ranks"
bash scripts/multiome/background_signal/03_get_background_fragment_ranks.sh \
    out/multiome/background_signal/FucciCA2_E14_sorted_P3/atac_background_fragments.bed \
    out/external/replication_timing/GSE102077/GSE102076_Population_repli-seq_ranks.tsv \
    out/multiome/background_signal/FucciCA2_E14_sorted_P3/atac_background_fragments_population_ranks.bed


echo "Running on single cell data ranks"
bash scripts/multiome/background_signal/03_get_background_fragment_ranks.sh \
    out/multiome/background_signal/FucciCA2_E14_sorted_P3/atac_background_fragments.bed \
    out/external/replication_timing/GSE102077/GSE102074_singlecell_binarized_ranks.tsv \
    out/multiome/background_signal/FucciCA2_E14_sorted_P3/atac_background_fragments_singlecell_ranks.bed


echo "Running on single cell data ranks without na filtering"
bash scripts/multiome/background_signal/03_get_background_fragment_ranks.sh \
    out/multiome/background_signal/FucciCA2_E14_sorted_P3/atac_background_fragments.bed \
    out/external/replication_timing/GSE102077/GSE102074_singlecell_binarized_ranks_with_na.tsv \
    out/multiome/background_signal/FucciCA2_E14_sorted_P3/atac_background_fragments_singlecell_ranks_with_na.bed
##################################


echo "DONE" 
