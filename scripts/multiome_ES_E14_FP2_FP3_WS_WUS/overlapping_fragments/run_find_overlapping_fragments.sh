 #!/bin/bash
#SBATCH --mem-per-cpu=15G
#SBATCH -c 4
#SBATCH --time=3-00:00:00
#SBATCH -p long
#SBATCH --job-name=run_find_overlapping_fragments.sh
#SBATCH --output=/gpfs3/well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/overlapping_fragments/log/%x-%j.log

#bash scripts/multiome/overlapping_fragments/find_overlapping_fragments.sh \
#    out/multiome/background_signal/FucciCA2_E14_sorted_allpop/atac_background_fragments.bed \
#    test.bed

# This scripts calls find_overlapping_fragments.sh with different input parameters

echo "Running on FucciCA2_E14_sorted_allpop"
#bash scripts/multiome/overlapping_fragments/find_overlapping_fragments.sh \
#    /well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/cellranger/FucciCA2_E14_sorted_allpop/outs/atac_fragments.tsv.gz \
#    /well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/overlapping_fragments/FucciCA2_E14_sorted_allpop

echo "Running on FucciCA2_E14_sorted_P3"
bash scripts/multiome/overlapping_fragments/find_overlapping_fragments.sh \
    /well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/cellranger/FucciCA2_E14_sorted_P3/outs/atac_fragments.tsv.gz \
    /well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/overlapping_fragments/FucciCA2_E14_sorted_P3

echo "Running on ES_E14_sorted"
bash scripts/multiome/overlapping_fragments/find_overlapping_fragments.sh \
    /well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/cellranger/ES_E14_sorted/outs/atac_fragments.tsv.gz \
    /well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/overlapping_fragments/ES_E14_sorted

echo "Running on ES_E14_unsorted"
bash scripts/multiome/overlapping_fragments/find_overlapping_fragments.sh \
    /well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/cellranger/ES_E14_unsorted/outs/atac_fragments.tsv.gz \
    /well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/out/multiome/overlapping_fragments/ES_E14_unsorted

echo "DONE"
