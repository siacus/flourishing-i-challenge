#!/bin/sh -l
# (c) SMI 2025
# FILENAME: process_classify.sbatch

#SBATCH --gres=gpu:1          # Request 1 GPU
#SBATCH --gpus-per-node=1     # Number of GPUs per node            
#SBATCH -p ghx4 # the default queue is "shared" queue
#SBATCH --nodes=1
#SBATCH --ntasks=1 
#SBATCH --requeue 
#SBATCH --mail-user=siacus@iq.harvard.edu
#SBATCH --mail-type=all       # Send email to above address at begin and end of job
#SBATCH --account=befu-dtai-gh
 
# Manage processing environment, load compilers and applications.
module purge
# Load necessary modules
module load nvhpc-openmpi3/24.3
module load gcc/11.4.0
module load nvhpc-hpcx-cuda12

# Print the hostname of the compute node on which this job is running.
hostname

# Directly specify the Python executable from the gpu environment
cd /u/siacus/all # should point to the dir of classify.py
/u/siacus/miniconda3/envs/cuda/bin/python classify.py ${1}


