#!/bin/sh -l
# (c) SMI 2025
# FILENAME: process_classify.sbatch

#SBATCH -A soc250007-gpu
#SBATCH --gres=gpu:1          # Request 1 GPU
#SBATCH --gpus-per-node=1     # Number of GPUs per node            
#SBATCH -p gpu # the default queue is "shared" queue
#SBATCH --nodes=1
#SBATCH --ntasks=1 
#SBATCH --requeue 
#SBATCH --mail-user=siacus@iq.harvard.edu
#SBATCH --mail-type=all       # Send email to above address at begin and end of job

 
# Manage processing environment, load compilers and applications.
module purge
# Load necessary modules
module load modtree/gpu   # default gcc and cuda version too old
module load cuda/11  # the version of cuda and gcc shold match on this cluster
module load gcc/11
module load anaconda
module list
conda activate cuda

# Print the hostname of the compute node on which this job is running.
hostname

# Directly specify the Python executable from the gpu environment
cd /home/x-siacus/all   # should point to dir of classify.py
python classify.py ${1}



