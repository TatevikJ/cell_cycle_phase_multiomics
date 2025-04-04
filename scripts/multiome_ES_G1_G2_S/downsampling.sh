#!/bin/bash
#SBATCH --mem-per-cpu=40G
#SBATCH -c 4
#SBATCH -p long
#SBATCH --output=log/downsampling-slurm-%j.out

#This script randomly samples n number of raw read pairs from all fastqs of a sample combined

#-------------------------------MODULEs-------------------------------
#seqtk (Version: 1.4-r132-dirty) used

#-------------------------------INPUTS--------------------------------
data_dir='data/raw/multiome_ES_G1_G2_S/ATAC'
out_dir_prefix='data/raw/multiome_ES_G1_G2_S/ATAC_downsampled'

#-------------------------------RUN SCRIPT----------------------------
# Define cell counts for each sample
declare -A cell_counts=( ["G1"]=6163 ["G2"]=7390 ["S"]=15818 )

#for s in G1 G2 S; do
for s in S; do

    # Get the cell count for the current sample
    n_cells=${cell_counts[$s]}
    #for n_reads in 5000 10000 12500 15000 17500 20000; do
    for n_reads in 12500 15000 17500 20000; do

	n_sampled_reads=$((n_reads * n_cells))
	echo -e "\nGetting random sample of ${n_sampled_reads} read pairs (n_cells:${n_cells}, n_reads:${n_reads}) for ${s} sample...\n"
	# Create output directory
	mkdir -p ${out_dir_prefix}_${n_reads}/${s}
	
	echo -e "\nI1...\n"
	# Merge and downsample reads using same seed (1) for all fastq read types
	zcat ${data_dir}/${s}/${s}_S1_L001_I1_001.fastq.gz \
	     ${data_dir}/${s}/${s}_S1_L002_I1_001.fastq.gz \
	     ${data_dir}/${s}/${s}_S1_L003_I1_001.fastq.gz \
	     ${data_dir}/${s}/${s}_S1_L004_I1_001.fastq.gz | \
	    ~/seqtk/seqtk sample -s1 - ${n_sampled_reads} | \
	    gzip > ${out_dir_prefix}_${n_reads}/${s}/${s}_S1_L001_I1_001.fastq.gz
	
	echo -e "\nR1...\n"
	zcat ${data_dir}/${s}/${s}_S1_L001_R1_001.fastq.gz \
	     ${data_dir}/${s}/${s}_S1_L002_R1_001.fastq.gz \
	     ${data_dir}/${s}/${s}_S1_L003_R1_001.fastq.gz \
	     ${data_dir}/${s}/${s}_S1_L004_R1_001.fastq.gz | \
	    ~/seqtk/seqtk sample -s1 - ${n_sampled_reads} | \
	    gzip > ${out_dir_prefix}_${n_reads}/${s}/${s}_S1_L001_R1_001.fastq.gz
	
	echo -e "\nR2...\n"
	zcat ${data_dir}/${s}/${s}_S1_L001_R2_001.fastq.gz \
	     ${data_dir}/${s}/${s}_S1_L002_R2_001.fastq.gz \
	     ${data_dir}/${s}/${s}_S1_L003_R2_001.fastq.gz \
	     ${data_dir}/${s}/${s}_S1_L004_R2_001.fastq.gz | \
	    ~/seqtk/seqtk sample -s1 - ${n_sampled_reads} | \
	    gzip > ${out_dir_prefix}_${n_reads}/${s}/${s}_S1_L001_R2_001.fastq.gz
	
	echo -e "\nR3...\n"
	zcat ${data_dir}/${s}/${s}_S1_L001_R3_001.fastq.gz \
	     ${data_dir}/${s}/${s}_S1_L002_R3_001.fastq.gz \
	     ${data_dir}/${s}/${s}_S1_L003_R3_001.fastq.gz \
	     ${data_dir}/${s}/${s}_S1_L004_R3_001.fastq.gz | \
	    ~/seqtk/seqtk sample -s1 - ${n_sampled_reads} | \
	    gzip > ${out_dir_prefix}_${n_reads}/${s}/${s}_S1_L001_R3_001.fastq.gz
    done
done

echo 'DONE'
