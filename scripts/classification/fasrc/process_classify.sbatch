#!/bin/sh -l
# (c) SMI 2025
# FILENAME: process_classify.sbatch

#SBATCH --gres=gpu:1          # Request 1 GPU
#SBATCH --gpus-per-node=1     # Number of GPUs per node            
#SBATCH --partition=gpu_requeue # Partition name for GPU jobs
#SBATCH --nodes=1
#SBATCH --ntasks=1 
#SBATCH --requeue 
#SBATCH --mail-user=siacus@iq.harvard.edu
#SBATCH --mail-type=FAIL       # Send email to above address at begin and end of job
#SBATCH --cpus-per-task=2                 # Request 2 CPU core
#SBATCH --constraint="h100|a100" # do not change this !!!!
#SBATCH --mem=25G
#SBATCH -x holygpu7c0920,holygpu8a25104,holygpu8a19604


# FASRC:
module load nvhpc/23.7-fasrc01
module load cuda/12.2.0-fasrc01 
module load gcc/12.2.0-fasrc01

# Print the hostname of the compute node on which this job is running.
hostname

# should point where classify.py exists
cd /n/netscratch/siacus_lab/Lab/scripts
/n/home11/siacus/miniconda3/envs/cuda/bin/python classify.py ${1}





