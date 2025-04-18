# Scripts for Fine-Tuning, Classification and Statistical Analysis 
These directory contain scripts for
* [finetuning](./finetuning) of LLMs
* [classification](./classification) of raw tweets
* construction of statistical [indicators](./indicators)

These scripts should work on Anvil, Delta-AI and FASRC clusters. But read below before trying to run them.

What follows is a simplified set of instructions for replicability and some notes that we find useful.
Some tweaking are inevitable, like changing the account, allocation, SLURM partition names and folders.

These scripts assume you have an account on an ACCESS cluster or FARSC.
## ACCESS accounts: Anvil
* create an ACCESS account [here](https://operations.access-ci.org/identity/new-user) 
* login via SSH: follow the instructions [here](https://www.rcac.purdue.edu/knowledge/anvil/access/login). Essentially: First login to the web [Open OnDemand interface](https://ondemand.anvil.rcac.purdue.edu) using your ACCESS username and password, and then upload your public key by launching a shell from ODD console.
* configuring VSCODE: I find this [link](https://github.com/KempnerInstitute/kempner-computing-handbook/blob/main/kempner_computing_handbook/development_and_runtime_envs/using_vscode_for_remote_development.md) useful
* general instructions on how to run jobs on Anvil [here](https://www.rcac.purdue.edu/knowledge/anvil/run), and specifically [GPU jobs](https://www.rcac.purdue.edu/knowledge/anvil/run/examples/slurm)
* home directory ```/home/x-siacus``` (adjust)
* project directory:  ```$PROJECT``` or ```/anvil/projects/x-soc250007``` (adjust)
* scratch folder: ```/anvil/scratch/x-siacus/``` (adjust)

## ACCESS accounts: Delta-AI
* create an ACCESS account [here](https://operations.access-ci.org/identity/new-user) 
* login via SSH: follow the instructions [here](https://docs.ncsa.illinois.edu/systems/deltaai/en/latest/user-guide/login.html#ssh-examples).
* [Open OnDemand interface](https://gh-ondemand.delta.ncsa.illinois.edu/) using your NCSA username and password.
* configuring VSCODE: read this [page](https://docs.ncsa.illinois.edu/systems/deltaai/en/latest/user-guide/vscode/remote-ssh.html)
* general instructions on how to run jobs on Delta-AI [here](https://docs.ncsa.illinois.edu/systems/deltaai/en/latest/user-guide/running-jobs.html#partitions-queues)
* home directory ```/u/siacus``` (adjust)
* project directory:  ```$PROJECT``` or ```/projects/befu/siacus/``` (adjust)

## FASRC accounts
* login via SSH: follow the instructions [here](https://docs.rc.fas.harvard.edu/kb/ssh-to-a-compute-node/). Essentially: First login to the web [Open OnDemand interface](https://rcood.rc.fas.harvard.edu/pun/sys/dashboard/) using your FASRC username and password, and then upload your public key by launching a shell from ODD console.
* configuring VSCODE: I find this [link](https://github.com/KempnerInstitute/kempner-computing-handbook/blob/main/kempner_computing_handbook/development_and_runtime_envs/using_vscode_for_remote_development.md) useful
* general instructions on how to run jobs on FASRC [here](https://docs.rc.fas.harvard.edu/kb/running-jobs/), and specifically [GPU jobs](https://docs.rc.fas.harvard.edu/wp-content/uploads/2013/10/GPU_Computing_9_26.pdf)
* home directory ```/n/home11/siacus``` (adjust)
* scratch folder: ```/n/netscratch/siacus_lab``` (adjust)

#### Useful SLURM commands
* to know which partitions are available: ```showpartitions```
* to know jour jobs: ```squeue | grep siacus```   # (adjust username)
* to kill one of jour jobs: ```scancel job_num```
* to kill all your jobs: ```scancel -u $USER```

  
## Setting up a Conda Environment
All scripts run in a conda environment DO NOT USE MAMBA !

* How to build the conda environment that can be used for both fine-tuning and inference
#### Cluster modules for FASRC
```
module load nvhpc/23.7-fasrc01
module load cuda/12.2.0-fasrc01 
module load gcc/12.2.0-fasrc01
```
#### Cluster modules for Anvil
```
module purge
module load anaconda
```
#### Cluster modules for Delta-AI
```
module purge
module load nvhpc-openmpi3/24.3
module load gcc/11.4.0
module load nvhpc-hpcx-cuda12
```
* Building the actual environment
```
conda create -n cuda python=3.10
conda activate cuda
pip3 install accelerate peft bitsandbytes transformers trl
pip install huggingface-hub 
huggingface-cli login     # [ and pass read/write token]
pip install wandb  # wandb will ask for the same type of authentication on the first use
pip install psutil
pip install pandas tqdm datasets # should be already installed
````
* LLAMA-CPP-PYTHON installation for A100, H100 and H200
```
conda activate cuda
pip install llama-cpp-python \
  --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cu122 \
  --force-reinstall --verbose
```
This is crucial if you use clusters with different versions of NVIDIA GPUs.

* Testing the environment
After spinning the VMs (see the examples below) always load the modules and the conda environment
```
conda activate cuda
```
#### On Anvil (adjust the allocation)
generic: 

```sinteractive -p shared  -N 1 -n 4 -A soc250007 -t 2:0:0```

for the gpu:

```sinteractive -p gpu -N 1 -n 4 -A soc250007-gpu --gres=gpu:1 -t 2:0:0```

#### On Delta-AI (adjust the allocation)
generic: 

```sinteractive -p shared  -N 1 -n 4 -A soc250007 -t 2:0:0```

for the gpu:

```
salloc --mem=16g --nodes=1 --ntasks-per-node=1 --cpus-per-task=2 \
  --partition=ghx4 \
  --account=befu-dtai-gh --time=00:30:00 --gpus-per-node=1
```


#### On Fasrc
generic: 

```salloc -p test  --ntasks=1 --cpus-per-task=4 --mem=32G -t 120```

for the gpu: 

```salloc -p gpu_test --gres=gpu:1 --mem=40G -N 1 -t 120```

## Lesson Learned
Although the three clusters use SLURM, OOD and same GPUs, you need to spend some time in figuring out the correct modules to load.
SLURM on Anvil does not support ```--requeue``` which can be useful in our case.
After iterating on three clusters, in the end the scripts are more robust than their original versions.
