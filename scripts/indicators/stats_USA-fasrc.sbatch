#!/bin/sh -l
# (c) SMI 2025

# FILENAME: stats_USA-fasrc.sbatch

#SBATCH --partition=test  
#SBATCH --nodes=1
#SBATCH --ntasks=1 
#SBATCH --mail-user=siacus@iq.harvard.edu
#SBATCH --mail-type=ALL   
#SBATCH --cpus-per-task=32                 
#SBATCH --mem=512G             
#SBATCH --requeue 
 
# FASRC:
module load R
hostname
cd /n/netscratch/siacus_lab/Lab/scripts
Rscript generate_stats.R
Rscript save_stats.R
Rscript calculate_maps.R










