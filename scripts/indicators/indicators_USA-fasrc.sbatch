#!/bin/sh -l
# (c) SMI 2025
# FILENAME: indicators_USA-fasrc.sbatch

#SBATCH --partition=shared   
#SBATCH --nodes=1
#SBATCH --ntasks=1 
#SBATCH --requeue 
#SBATCH --mail-user=siacus@iq.harvard.edu
#SBATCH --mail-type=FAIL   
#SBATCH --cpus-per-task=8                 
#SBATCH --mem=32G             

 
# FASRC:
module load R
hostname
cd /n/netscratch/siacus_lab/Lab/scripts
Rscript generate_indicators.R







