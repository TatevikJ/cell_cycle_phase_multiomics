#!/bin/bash
#SBATCH --mem-per-cpu=30G
#SBATCH -c 4
#SBATCH -p long
#SBATCH --output=log/pipeline-slurm-%j.out   # %j will be replaced with the Job ID

#same as pipeline.sh but takes as input csv file with paths instead of cellranger directory

#-----------------------LOAD REQUIRED MODULES-----------------------
source env-skylake/bin/activate
module load BEDTools/2.31.0-GCC-12.3.0

#-------------------------------INPUTS--------------------------------
INPUT_PATHS_CSV=$1
GENE_REGIONS_BED=$2
RT_TSV=$3
OUTPUT_DIR=$4

echo -e "\nRunning the pipeline, files will be stored in ${OUTPUT_DIR} directory...\n"

mkdir $OUTPUT_DIR

# Function to print the current time
print_time() {
    echo -e "\nCurrent time: $(date '+%Y-%m-%d %H:%M:%S')\n"
}

#-----------------------------RUN SCRIPT 1------------------------------
# Filter atac fragments by provided list of barcodes and keep only fragments from autosomal chromosomes
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nFiltering fragments for ${SAMPLE} sample...\n"
    
    mkdir ${OUTPUT_DIR}/${SAMPLE}
    
    # Check if BARCODES_PATH is gzipped
    if [[ ${BARCODES_PATH} == *.gz ]]; then
        zcat ${BARCODES_PATH} | awk 'NR==FNR {filter[$1]; next} $4 in filter' - <(zcat ${FRAGMENTS_PATH}) \
		  > ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_filtered.tsv
    else
        zcat ${FRAGMENTS_PATH} | awk 'NR==FNR {filter[$1]; next} $4 in filter' ${BARCODES_PATH} - \
		  > ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_filtered.tsv
    fi
    
    gzip ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_filtered.tsv
done

# Outputs: ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_filtered.tsv.gz


#-----------------------------RUN SCRIPT 1------------------------------
# Get background and other types of fragments for each sample

# 1. Exclude nothing
# use ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_filtered.tsv.gz in further steps

# 2. Exclude peaks
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nGetting background fragments for ${SAMPLE} sample...\n"

    bedtools intersect -v \
	     -a ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_filtered.tsv.gz \
	     -b ${PEAKS_PATH} \
	     > ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments.bed
done

# 3. Exclude peaks+intragenic regions
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nExcluding background fragments from intagenic regions for ${SAMPLE} sample...\n"

    bedtools intersect -v \
	     -a ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments.bed \
	     -b ${GENE_REGIONS_BED} \
	     > ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions.bed
done

# 4. Get peaks
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nGetting fragments in peaks for ${SAMPLE} sample...\n"

    bedtools intersect -wa \
	     -a ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_filtered.tsv.gz \
	     -b ${PEAKS_PATH} \
	     > ${OUTPUT_DIR}/${SAMPLE}/atac_peak_fragments.bed
done

Outputs: ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments.bed
         ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions.bed

#-----------------------------RUN SCRIPT 2----------------------------
# Note: preprocessing of RT data not included, this step takes data with 3 columns (chromosome, bin start position, rt value)
# Get replication ranks per bin for each sample and each RT data

# python v3.11.3
print_time
echo -e "\nGetting replication ranks per bin...\n"
python scripts/get_replication_ranks_per_bin.py $RT_TSV ${OUTPUT_DIR}/rt_ranks.tsv

# Output: ${OUTPUT_DIR}/rt_ranks.tsv

#-----------------------------RUN SCRIPT 3----------------------------
# Get background fragment ranks for each sample

# 1. Exclude nothing
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nAssigning RT ranks to fragments by intersecting with 50kb bins having RT ranks for ${SAMPLE} sample...\n"

    bedtools intersect -wo \
             -a ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_filtered.tsv.gz \
             -b ${OUTPUT_DIR}/rt_ranks.tsv \
             > ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks.bed
done

# 2. Exclude peaks
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nAssigning RT ranks to fragments by intersecting with 50kb bins having RT ranks for ${SAMPLE} sample...\n"

    bedtools intersect -wo \
	     -a ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments.bed \
	     -b ${OUTPUT_DIR}/rt_ranks.tsv \
	     > ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks.bed
done

# 3. Exclude peaks+intragenic regions
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
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
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nProcessing fragment ranks for ${SAMPLE} sample...\n"

    python scripts/process_background_fragments_ranks.py \
           ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks.bed \
           ${BARCODES_PATH} \
           ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks_filtered.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks_counts_and_ratio_per_cell.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks_counts_and_ratio_per_cell_normalised.tsv
done

# 2. Exclude peaks
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nProcessing fragment ranks for ${SAMPLE} sample...\n"
    
    python scripts/process_background_fragments_ranks.py \
	   ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks.bed \
	   ${BARCODES_PATH} \
	   ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_filtered.tsv \
	   ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_counts_and_ratio_per_cell.tsv \
	   ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_counts_and_ratio_per_cell_normalised.tsv
done

# Exclude peaks+intragenic regions
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nProcessing fragment ranks for ${SAMPLE} sample...\n"

    python scripts/process_background_fragments_ranks.py \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks.bed \
           ${BARCODES_PATH} \
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
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nGetting overlapping fragments for ${SAMPLE} sample...\n"
    
    bedtools intersect \
	     -a ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_filtered.tsv.gz \
	     -b ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_filtered.tsv.gz \
	     -wo  \
             -sorted | \
	awk '$1 == $6 && ($2 != $7 || $3 != $8) && $4 == $9  && $2 < $7' - \
	    > ${OUTPUT_DIR}/${SAMPLE}/atac_overlapping_fragments.bed
done

# 2. Exclude peaks
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
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
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nGetting overlapping fragments for ${SAMPLE} sample excluding fragments from peak and gene regions...\n"
    
    bedtools intersect \
             -a ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions.bed \
             -b ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions.bed \
             -wo  \
             -sorted | \
	awk '$1 == $6 && ($2 != $7 || $3 != $8) && $4 == $9  && $2 < $7' - \
	    > ${OUTPUT_DIR}/${SAMPLE}/atac_overlapping_fragments_exclude_peak_gene_regions.bed
done

# 4. Only peak regions
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nGetting overlapping fragments for ${SAMPLE} sample only from peak regions...\n"
    
    bedtools intersect \
             -a ${OUTPUT_DIR}/${SAMPLE}/atac_peak_fragments.bed \
             -b ${OUTPUT_DIR}/${SAMPLE}/atac_peak_fragments.bed \
             -wo  \
             -sorted | \
	awk '$1 == $6 && ($2 != $7 || $3 != $8) && $4 == $9  && $2 < $7' - \
	    > ${OUTPUT_DIR}/${SAMPLE}/atac_overlapping_fragments_only_peak_regions.bed
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
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nProcessing overlapping fragments for ${SAMPLE} sample...\n"
    
    python scripts/process_overlapping_fragments.py \
           ${OUTPUT_DIR}/${SAMPLE}/atac_overlapping_fragments.bed \
           ${BARCODES_PATH} \
           ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_filtered.tsv.gz \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_filtered.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_counts_and_ratio_per_cell.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_counts_and_ratio_per_cell_normalised.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_peak_regions_only_background.csv
done

# 0. Exclude peaks and gene regions for early/late ratio and exclude nothing for overlapping fragments
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nProcessing overlapping fragments for ${SAMPLE} sample...\n"
    
    python scripts/process_overlapping_fragments.py \
           ${OUTPUT_DIR}/${SAMPLE}/atac_overlapping_fragments.bed \
           ${BARCODES_PATH} \
           ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_filtered.tsv.gz \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks_filtered.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks_counts_and_ratio_per_cell.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks_counts_and_ratio_per_cell_normalised.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_peak_gene_regions_only_background.csv
done

# 1. Exclude nothing
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nProcessing overlapping fragments for ${SAMPLE} sample...\n"
    
    python scripts/process_overlapping_fragments.py \
           ${OUTPUT_DIR}/${SAMPLE}/atac_overlapping_fragments.bed \
           ${BARCODES_PATH} \
    	   ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_filtered.tsv.gz \
    	   ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks_filtered.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks_counts_and_ratio_per_cell.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_ranks_counts_and_ratio_per_cell_normalised.tsv \
    	   ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_nothing.csv
done

# 2. Exclude peaks
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nProcessing overlapping fragments for ${SAMPLE} sample...\n"
    
    python scripts/process_overlapping_fragments.py \
           ${OUTPUT_DIR}/${SAMPLE}/atac_overlapping_fragments_exclude_peak_regions.bed \
           ${BARCODES_PATH} \
           ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_filtered.tsv.gz \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_filtered.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_counts_and_ratio_per_cell.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_counts_and_ratio_per_cell_normalised.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_peak_regions.csv
done

# 3. Exclude peaks+intragenic regions
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nProcessing overlapping fragments for ${SAMPLE} sample...\n"
    
    python scripts/process_overlapping_fragments.py \
           ${OUTPUT_DIR}/${SAMPLE}/atac_overlapping_fragments_exclude_peak_gene_regions.bed \
           ${BARCODES_PATH} \
           ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_filtered.tsv.gz \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks_filtered.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks_counts_and_ratio_per_cell.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_exclude_gene_regions_ranks_counts_and_ratio_per_cell_normalised.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_peak_gene_regions.csv
done

# 4. Exclude peaks for early/late ratio and use only peaks for overlapping fragments
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nProcessing overlapping fragments for ${SAMPLE} sample...\n"
    
    python scripts/process_overlapping_fragments.py \
           ${OUTPUT_DIR}/${SAMPLE}/atac_overlapping_fragments_only_peak_regions.bed \
           ${BARCODES_PATH} \
           ${OUTPUT_DIR}/${SAMPLE}/atac_fragments_filtered.tsv.gz \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_filtered.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_counts_and_ratio_per_cell.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/atac_background_fragments_ranks_counts_and_ratio_per_cell_normalised.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_only_peak_regions.csv
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
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nGenerating plots for ${SAMPLE} sample...\n"
    mkdir ${OUTPUT_DIR}/figures/exclude_peak_regions_only_background/${SAMPLE}
    
    python scripts/generate_plots.py \
    	   ${OUTPUT_DIR}/rt_ranks.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_peak_regions_only_background.csv \
    	   ${OUTPUT_DIR}/figures/exclude_peak_regions_only_background/${SAMPLE}
done

# 0. Exclude peaks and gene regions for early/late ratio and exclude nothing for overlapping fragments
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nGenerating plots for ${SAMPLE} sample...\n"
    mkdir ${OUTPUT_DIR}/figures/exclude_peak_gene_regions_only_background/${SAMPLE}
    
    python scripts/generate_plots.py \
    	   ${OUTPUT_DIR}/rt_ranks.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_peak_gene_regions_only_background.csv \
    	   ${OUTPUT_DIR}/figures/exclude_peak_gene_regions_only_background/${SAMPLE}
done

# 1. Exclude nothing
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nGenerating plots for ${SAMPLE} sample...\n"
    mkdir ${OUTPUT_DIR}/figures/exclude_nothing/${SAMPLE}
    
    python scripts/generate_plots.py \
           ${OUTPUT_DIR}/rt_ranks.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_nothing.csv \
           ${OUTPUT_DIR}/figures/exclude_nothing/${SAMPLE}
done

# 2. Exclude peaks
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nGenerating plots for ${SAMPLE} sample...\n"
    mkdir ${OUTPUT_DIR}/figures/exclude_peak_regions/${SAMPLE}
    
    python scripts/generate_plots.py \
           ${OUTPUT_DIR}/rt_ranks.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_peak_regions.csv \
           ${OUTPUT_DIR}/figures/exclude_peak_regions/${SAMPLE}
done

# 3. Exclude peaks+intragenic regions
awk -F, 'NR>1 {print $1,$2,$3,$4}' $INPUT_PATHS_CSV | while read SAMPLE PEAKS_PATH FRAGMENTS_PATH BARCODES_PATH; do
    print_time
    echo -e "\nGenerating plots for ${SAMPLE} sample...\n"
    mkdir ${OUTPUT_DIR}/figures/exclude_peak_gene_regions/${SAMPLE}
    
    python scripts/generate_plots.py \
           ${OUTPUT_DIR}/rt_ranks.tsv \
           ${OUTPUT_DIR}/${SAMPLE}/metrics_per_cell_exclude_peak_gene_regions.csv \
           ${OUTPUT_DIR}/figures/exclude_peak_gene_regions/${SAMPLE}
done

#-----------------------------------------------------------------------

print_time
echo -e "\nDONE\n"










