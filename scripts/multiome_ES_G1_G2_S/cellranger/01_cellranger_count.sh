#!/bin/bash

sbatch scripts/multiome_ES_G1_G2_S/cellranger/helper/G1_cellranger_count.sh
sbatch scripts/multiome_ES_G1_G2_S/cellranger/helper/G2_cellranger_count.sh
sbatch scripts/multiome_ES_G1_G2_S/cellranger/helper/S_cellranger_count.sh

