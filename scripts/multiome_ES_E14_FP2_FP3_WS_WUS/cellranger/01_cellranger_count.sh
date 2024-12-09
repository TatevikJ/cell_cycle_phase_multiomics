#!/bin/bash

sbatch helper/FP2_cellranger_count.sh
sbatch helper/FP3_cellranger_count.sh
sbatch helper/WS_cellranger_count.sh
sbatch helper/WUS_cellranger_count.sh
