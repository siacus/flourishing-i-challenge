#!/bin/sh -l
# (c) SMI 2025
# FILENAME: reset_db-fasrc.sbatch

#SBATCH --partition=test  
#SBATCH --nodes=1
#SBATCH --ntasks=1 
#SBATCH --requeue 
#SBATCH --mail-user=siacus@iq.harvard.edu
#SBATCH --mail-type=ALL   
#SBATCH --cpus-per-task=32                 
#SBATCH --mem=64G             

 
# FASRC:
module load R
hostname
cd /n/netscratch/siacus_lab/Lab/scripts
Rscript reset_db.R







