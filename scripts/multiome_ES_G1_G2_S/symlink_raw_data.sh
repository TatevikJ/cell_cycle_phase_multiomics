##!/bin/bash

raw_data_dir='/well/beagrie/shared/raw-data/cell-cycle-multiome/40-1078013634/00_fastq'
symlink_dir='/well/beagrie/users/ysx978/projects/cell_cycle_phase_multiomics/data/raw/multiome_ES_G1_G2_S'

cd ${raw_data_dir}

# Loop through all FASTQ files
for file in *.fastq.gz; do
    echo "Running on $file..."
    # Extract the group (G1, G2, S) based on the filename
    sample=$(echo ${file} | cut -d'-' -f2)
    
    # Extract the type (ATAC, GEX) based on the filename
    type=$(echo ${file} | cut -d'-' -f3 | cut -d'_' -f1)

    if [[ "$type" == "ATAC" ]]; then
        # Extract 1_R1_ part
	ending=$(echo ${file} | cut -d'-' -f4)
    elif [[ "$type" == "GEX" ]]; then
        # Extract R1_ part and add 1_ at the beginning 
	ending=1_$(echo ${file} | cut -d'_' -f2-)
    else
        echo "Unknown type"
    fi
    
    
    # Create a symlink in the appropriate directory
    ln -s ${raw_data_dir}/${file} ${symlink_dir}/${type}/${sample}/${sample}_S1_L00${ending}

    echo ${raw_data_dir}/${file}
    echo ${symlink_dir}/${type}/${sample}/${sample}_S1_L00${ending}
done

echo 'DONE'
