#!/bin/sh -l
# FILENAME: process_classify-batch.sbatch

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


 
# ANVIL: Manage processing environment, load compilers and applications.
# module purge
# # Load necessary modules
# module load modtree/gpu   # default gcc and cuda version too old
# module load cuda/11  # the version of cuda and gcc shold match on this cluster
# module load gcc/11
# module load anaconda
# module list
# conda activate jago

# FASRC:
module load nvhpc/23.7-fasrc01
module load cuda/12.2.0-fasrc01 
module load gcc/12.2.0-fasrc01

# Print the hostname of the compute node on which this job is running.
hostname

cd /n/netscratch/siacus_lab/Lab/scripts

# DEVIKA/ANDREA: change this next line to your own conda
# e.g. /n/home11/devika/miniconda3/envs/jago/bin/python classify-fasrc.py ${1}
/n/home11/siacus/miniconda3/envs/cuda/bin/python classify-fasrc.py ${1}





