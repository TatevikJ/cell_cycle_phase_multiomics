#!/bin/bash
#SBATCH --mem-per-cpu=30G
#SBATCH -c 4
#SBATCH -p long
#SBATCH --output=log/pipeline-slurm-%j.out   # %j will be replaced with the Job ID

#-----------------------LOAD REQUIRED MODULES-----------------------
source env-skylake/bin/activate
module load BEDTools/2.31.0-GCC-12.3.0

#-------------------------------INPUTS--------------------------------
CELLRANGER_OUT_DIR=$1
SAMPLES=($2)
GENE_REGIONS_BED=$3
RT_TSV=$4

OUTPUT_DIR=$5
mkdir $OUTPUT_DIR

echo -e "\nRunning the pipeline, files will be stored in ${OUTPUT_DIR} directory...\n"

#-----------------------------RUN SCRIPT 1------------------------------
# Get background fragments for each sample

# 1. Exclude nothing
# use ${CELLRANGER_OUT_DIR}/${SAMPLE}/outs/atac_fragments.tsv.gz in further steps

# 2. Exclude peaks
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nGetting background fragments for ${SAMPLE} sample...\n"

    mkdir ${OUTPUT_DIR}/${SAMPLE}
    
    bedtools intersect -v \
	     -a ${CELLRANGER_OUT_DIR}/${SAMPLE}/outs/atac_fragments.tsv.gz \
	     -b ${CELLRANGER_OUT_DIR}/${SAMPLE}/outs/atac_peaks.bed \
	     > ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments.bed
done

# 3. Exclude peaks+intragenic regions
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nExcluding background fragments from intagenic regions for ${SAMPLE} sample...\n"

    bedtools intersect -v \
	     -a ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments.bed \
	     -b ${GENE_REGIONS_BED} \
	     > ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions.bed
done

# Outputs: ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments.bed
#          ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions.bed


#-----------------------------RUN SCRIPT 2----------------------------
# Note: preprocessing of RT data not included, this step takes data with 3 columns (chromosome, bin start position, rt value)
# Get replication ranks per bin for each sample and each RT data

# python v3.11.3
python scripts/get_replication_ranks_per_bin.py $RT_TSV ${OUTPUT_DIR}/rt_ranks.tsv

# Output: ${OUTPUT_DIR}/rt_ranks.tsv

#-----------------------------RUN SCRIPT 3----------------------------
# Get background fragment ranks for each sample

# 1. Exclude nothing
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nAssigning RT ranks to fragments by intersecting with 50kb bins having RT ranks for ${SAMPLE} sample...\n"

    bedtools intersect -wo \
             -a ${CELLRANGER_OUT_DIR}/${SAMPLE}/outs/atac_fragments.tsv.gz \
             -b ${OUTPUT_DIR}/rt_ranks.tsv \
             > ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks.bed
done

# 2. Exclude peaks
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nAssigning RT ranks to fragments by intersecting with 50kb bins having RT ranks for ${SAMPLE} sample...\n"

    bedtools intersect -wo \
	     -a ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments.bed \
	     -b ${OUTPUT_DIR}/rt_ranks.tsv \
	     > ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks.bed
done

# 3. Exclude peaks+intragenic regions
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nAssigning RT ranks to fragments by intersecting with 50kb bins having RT ranks for ${SAMPLE} sample...\n"

    bedtools intersect -wo \
             -a ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions.bed \
             -b ${OUTPUT_DIR}/rt_ranks.tsv \
             > ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks.bed
done

# Outputs: ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks.bed
#          ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks.bed
#          ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks.bed


#-----------------------------RUN SCRIPT 4----------------------------
# Filter background fragment ranks
# Get rank counts and ratio per cell
# Normalise ratio

# 1. Exclude nothing
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nProcessing fragment ranks for ${SAMPLE} sample...\n"

    python scripts/process_background_fragments_ranks.py \
           ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks.bed \
           ${CELLRANGER_OUT_DIR}/${SAMPLE}/outs/filtered_feature_bc_matrix/barcodes.tsv.gz \
           ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks_filtered.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks_counts_and_ratio_per_cell.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks_counts_and_ratio_per_cell_normalised.tsv
done

# 2. Exclude peaks
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nProcessing fragment ranks for ${SAMPLE} sample...\n"
    
    python scripts/process_background_fragments_ranks.py \
	   ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks.bed \
	   ${CELLRANGER_OUT_DIR}/${SAMPLE}/outs/filtered_feature_bc_matrix/barcodes.tsv.gz \
	   ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_filtered.tsv \
	   ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_counts_and_ratio_per_cell.tsv \
	   ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_counts_and_ratio_per_cell_normalised.tsv
done

# Exclude peaks+intragenic regions
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nProcessing fragment ranks for ${SAMPLE} sample...\n"

    python scripts/process_background_fragments_ranks.py \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks.bed \
           ${CELLRANGER_OUT_DIR}/${SAMPLE}/outs/filtered_feature_bc_matrix/barcodes.tsv.gz \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks_filtered.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks_counts_and_ratio_per_cell.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks_counts_and_ratio_per_cell_normalised.tsv
done

# Outputs: ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks_filtered.tsv
#          ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks_counts_and_ratio_per_cell.tsv 
#          ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks_counts_and_ratio_per_cell_normalised.tsv
#          ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_filtered.tsv
#          ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_counts_and_ratio_per_cell.tsv 
#          ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_counts_and_ratio_per_cell_normalised.tsv
#          ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks_filtered.tsv
#          ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks_counts_and_ratio_per_cell.tsv 
#          ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks_counts_and_ratio_per_cell_normalised.tsv


#-----------------------------RUN SCRIPT 5----------------------------
# Get overlapping fragments for each sample

# 1. Exclude nothing
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nGetting overlapping fragments for ${SAMPLE} sample...\n"

    bedtools intersect \
	     -a ${CELLRANGER_OUT_DIR}/${SAMPLE}/outs/atac_fragments.tsv.gz \
	     -b ${CELLRANGER_OUT_DIR}/${SAMPLE}/outs/atac_fragments.tsv.gz \
	     -wo  \
         -sorted | \
	awk '$1 == $6 && ($2 != $7 || $3 != $8) && $4 == $9  && $2 < $7' - \
	    > ${OUTPUT_DIR}/${SAMPLE}/atac_overlapping_fragments.bed
done

# 2. Exclude peaks
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nGetting overlapping fragments for ${SAMPLE} sample excluding fragments from peak regions...\n"
    
    bedtools intersect \
             -a ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments.bed \
             -b ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments.bed \
             -wo \
             -sorted | \
        awk '$1 == $6 && ($2 != $7 || $3 != $8) && $4 == $9  && $2 < $7' - \
            > ${OUTPUT_DIR}/${SAMPLE}/atac_overlapping_fragments_exclude_peak_regions.bed
done

# 3. Exclude peaks+intragenic regions
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nGetting overlapping fragments for ${SAMPLE} sample excluding fragments from peak and gene regions...\n"

    bedtools intersect \
             -a ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions.bed \
             -b ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions.bed \
             -wo  \
             -sorted | \
        awk '$1 == $6 && ($2 != $7 || $3 != $8) && $4 == $9  && $2 < $7' - \
            > ${OUTPUT_DIR}/${SAMPLE}/atac_overlapping_fragments_exclude_peak_gene_regions.bed
done


# Outputs: ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments.bed
#          ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions.bed
#          ${OUTPUT_DIR}/${SAMPLE}/atac_overlapping_fragments_exclude_peak_gene_regions.bed


#-----------------------------RUN SCRIPT 6----------------------------
# Filter overlapping fragments by cell barcode list
# Count number of overlapping fragments per cell
# Normalise by number of fragments per cell 
# Create file with all summary metrics per cell

# 0. Exclude peaks for early/late ratio and exclude nothing for overlapping fragments
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nProcessing overlapping fragments for ${SAMPLE} sample...\n"
    
    python scripts/process_overlapping_fragments.py \
           ${OUTPUT_DIR}/${SAMPLE}/atac_overlapping_fragments.bed \
           ${CELLRANGER_OUT_DIR}/${SAMPLE}/outs/filtered_feature_bc_matrix/barcodes.tsv.gz \
           ${CELLRANGER_OUT_DIR}/${SAMPLE}/outs/atac_fragments.tsv.gz \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_filtered.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_counts_and_ratio_per_cell.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_counts_and_ratio_per_cell_normalised.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_peak_regions_only_background.csv
done

# 0. Exclude peaks and gene regions for early/late ratio and exclude nothing for overlapping fragments
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nProcessing overlapping fragments for ${SAMPLE} sample...\n"
    
    python scripts/process_overlapping_fragments.py \
           ${OUTPUT_DIR}/${SAMPLE}/atac_overlapping_fragments.bed \
           ${CELLRANGER_OUT_DIR}/${SAMPLE}/outs/filtered_feature_bc_matrix/barcodes.tsv.gz \
           ${CELLRANGER_OUT_DIR}/${SAMPLE}/outs/atac_fragments.tsv.gz \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks_filtered.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks_counts_and_ratio_per_cell.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks_counts_and_ratio_per_cell_normalised.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_peak_gene_regions_only_background.csv
done

# 1. Exclude nothing
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nProcessing overlapping fragments for ${SAMPLE} sample...\n"
    
    python scripts/process_overlapping_fragments.py \
           ${OUTPUT_DIR}/${SAMPLE}/atac_overlapping_fragments.bed \
           ${CELLRANGER_OUT_DIR}/${SAMPLE}/outs/filtered_feature_bc_matrix/barcodes.tsv.gz \
    	   ${CELLRANGER_OUT_DIR}/${SAMPLE}/outs/atac_fragments.tsv.gz \
    	   ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks_filtered.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks_counts_and_ratio_per_cell.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks_counts_and_ratio_per_cell_normalised.tsv \
    	   ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_nothing.csv
done

# 2. Exclude peaks
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nProcessing overlapping fragments for ${SAMPLE} sample...\n"
    
    python scripts/process_overlapping_fragments.py \
           ${OUTPUT_DIR}/${SAMPLE}/atac_overlapping_fragments_exclude_peak_regions.bed \
           ${CELLRANGER_OUT_DIR}/${SAMPLE}/outs/filtered_feature_bc_matrix/barcodes.tsv.gz \
           ${CELLRANGER_OUT_DIR}/${SAMPLE}/outs/atac_fragments.tsv.gz \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_filtered.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_counts_and_ratio_per_cell.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_counts_and_ratio_per_cell_normalised.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_peak_regions.csv
done

# 3. Exclude peaks+intragenic regions
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nProcessing overlapping fragments for ${SAMPLE} sample...\n"
    
    python scripts/process_overlapping_fragments.py \
           ${OUTPUT_DIR}/${SAMPLE}/atac_overlapping_fragments_exclude_peak_gene_regions.bed \
           ${CELLRANGER_OUT_DIR}/${SAMPLE}/outs/filtered_feature_bc_matrix/barcodes.tsv.gz \
           ${CELLRANGER_OUT_DIR}/${SAMPLE}/outs/atac_fragments.tsv.gz \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks_filtered.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks_counts_and_ratio_per_cell.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks_counts_and_ratio_per_cell_normalised.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_peak_gene_regions.csv
done

# Outputs: ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_nothing.csv
#          ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_peak_regions.csv
#          ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_peak_gene_regions.csv


#-----------------------------RUN SCRIPT 7----------------------------
# Plots
mkdir ${OUTPUT_DIR}/figures
mkdir ${OUTPUT_DIR}/figures/exclude_nothing
mkdir ${OUTPUT_DIR}/figures/exclude_peak_regions
mkdir ${OUTPUT_DIR}/figures/exclude_peak_regions_only_background
mkdir ${OUTPUT_DIR}/figures/exclude_peak_gene_regions
mkdir ${OUTPUT_DIR}/figures/exclude_peak_gene_regions_only_background


# 0. Exclude peaks for early/late ratio and exclude nothing for overlapping fragments
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nGenerating plots for ${SAMPLE} sample...\n"
    mkdir ${OUTPUT_DIR}/figures/exclude_peak_regions_only_background/${SAMPLE}
    
    python scripts/generate_plots.py \
    	   ${OUTPUT_DIR}/rt_ranks.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_peak_regions_only_background.csv \
    	   ${OUTPUT_DIR}/figures/exclude_peak_regions_only_background/${SAMPLE}
done

# 0. Exclude peaks and gene regions for early/late ratio and exclude nothing for overlapping fragments
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nGenerating plots for ${SAMPLE} sample...\n"
    mkdir ${OUTPUT_DIR}/figures/exclude_peak_gene_regions_only_background/${SAMPLE}
    
    python scripts/generate_plots.py \
    	   ${OUTPUT_DIR}/rt_ranks.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_peak_gene_regions_only_background.csv \
    	   ${OUTPUT_DIR}/figures/exclude_peak_gene_regions_only_background/${SAMPLE}
done

# 1. Exclude nothing
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nGenerating plots for ${SAMPLE} sample...\n"
    mkdir ${OUTPUT_DIR}/figures/exclude_nothing/${SAMPLE}
    
    python scripts/generate_plots.py \
           ${OUTPUT_DIR}/rt_ranks.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_nothing.csv \
           ${OUTPUT_DIR}/figures/exclude_nothing/${SAMPLE}
done

# 2. Exclude peaks
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nGenerating plots for ${SAMPLE} sample...\n"
    mkdir ${OUTPUT_DIR}/figures/exclude_peak_regions/${SAMPLE}
    
    python scripts/generate_plots.py \
           ${OUTPUT_DIR}/rt_ranks.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_peak_regions.csv \
           ${OUTPUT_DIR}/figures/exclude_peak_regions/${SAMPLE}
done

# 3. Exclude peaks+intragenic regions
for SAMPLE in "${SAMPLES[@]}"; do
    echo -e "\nGenerating plots for ${SAMPLE} sample...\n"
    mkdir ${OUTPUT_DIR}/figures/exclude_peak_gene_regions/${SAMPLE}

    python scripts/generate_plots.py \
           ${OUTPUT_DIR}/rt_ranks.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_peak_gene_regions.csv \
           ${OUTPUT_DIR}/figures/exclude_peak_gene_regions/${SAMPLE}
done

#-----------------------------------------------------------------------

echo -e "\nDONE\n"










