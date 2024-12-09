#!/bin/bash
# This scripts calls 01_get_background_fragments.sh with different input parameters

echo "Running on FucciCA2_E14_sorted_allpop"
bash scripts/background_signal/01_get_background_fragments.sh \
    /6/FucciCA2_E14_sorted_allpop/outs/atac_fragments.tsv.gz \
    /well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/cellranger/FucciCA2_E14_sorted_allpop/outs/atac_peaks.bed \
    /well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/background_signal/FucciCA2_E14_sorted_allpop

echo "Running on FucciCA2_E14_sorted_P3"
bash scripts/background_signal/01_get_background_fragments.sh \
    /well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/cellranger/FucciCA2_E14_sorted_P3/outs/atac_fragments.tsv.gz \
    /well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/cellranger/FucciCA2_E14_sorted_P3/outs/atac_peaks.bed \
    /well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/background_signal/FucciCA2_E14_sorted_P3

echo "Running on ES_E14_sorted"
bash scripts/background_signal/01_get_background_fragments.sh \
    /well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/cellranger/ES_E14_sorted/outs/atac_fragments.tsv.gz \
    /well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/cellranger/ES_E14_sorted/outs/atac_peaks.bed \
    /well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/background_signal/ES_E14_sorted

echo "Running on ES_E14_unsorted"
bash scripts/background_signal/01_get_background_fragments.sh \
    /well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/cellranger/ES_E14_unsorted/outs/atac_fragments.tsv.gz \
    /well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/cellranger/ES_E14_unsorted/outs/atac_peaks.bed \
    /well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/background_signal/ES_E14_unsorted

echo "DONE"
