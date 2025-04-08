# These scripts works for us on Anvil cluster. 
# What follows is a simplified set of instructions for replicability.
# You need to modify them by changing account, allocation and folders.

# Create an ACCESS account at https://operations.access-ci.org/identity/new-user 
# Login via SSH: follow the instructions here: https://www.rcac.purdue.edu/knowledge/anvil/access/login
# Essentially: First login to the web Open OnDemand interface at https://ondemand.anvil.rcac.purdue.edu using 
# your ACCESS username and password, and then upload your public key by launching a shell there.
# configuring VSCODE: I find this link useful
# https://github.com/KempnerInstitute/kempner-computing-handbook/blob/main/kempner_computing_handbook/development_and_runtime_envs/using_vscode_for_remote_development.md

# General instructions on how to run jobs on Anvil: https://www.rcac.purdue.edu/knowledge/anvil/run
# and specifically GPU jobs: https://www.rcac.purdue.edu/knowledge/anvil/run/examples/slurm
# showpartitions

# Home directory
# /home/x-siacus

# project directory:  $PROJECT  
# or: /anvil/projects/x-soc250007

# scratch folder:
# /anvil/scratch/x-siacus/

# All scripts run in a conda environment
# DO NOT USE MAMBA !
# How to build the conda environment that can be used for both fine-tuning and inference

# for FASRC
module load nvhpc/23.7-fasrc01
module load cuda/12.2.0-fasrc01 
module load gcc/12.2.0-fasrc01

# for Anvil


conda create -n cuda python=3.10
conda activate cuda
pip3 install accelerate peft bitsandbytes transformers trl
pip install huggingface-hub 
huggingface-cli login     # [ and pass read/write token]
pip install wandb  # wandb will ask for the same type of authentication on the first use
pip install psutil

### LLAMA-CPP-PYTHON installation for A100, H100 and H200
pip install llama-cpp-python \
  --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cu122 \
  --force-reinstall --verbose






# create the CPU setup
module load anaconda
conda create -n jagoCPU python=3.10
conda activate jagoCPU

sinteractive -p shared  -N 1 -n 4 -A soc250007 -t 2:0:0
module load anaconda
conda activate jagoCPU
pip install pandas tqdm datasets
# see https://pypi.org/project/llama-cpp-python/
pip install llama-cpp-python \
  --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cpu \
  --upgrade --force-reinstall --no-cache-dir
pip install psutil

### INSTRUCTIONS TO BUILD llama.ccp ###


# 1. spin a gpu instance
sinteractive -p gpu -N 1 -n 4 -A soc250007-gpu --gres=gpu:1 -t 2:0:0

# 2. setup to compile (and use) llama.cpp
module load modtree/gpu   # default gcc and cuda version too old

# module spider cuda    # to see the versions of cuda available
module load cuda/11  # the version of cuda and gcc shold match on this cluster
module load gcc/11

module list  # check the configuration
# Currently Loaded Modules:
#  1) modtree/gpu   3) mpfr/4.0.2   5) gcc/11.2.0    7) numactl/2.0.14   9) openmpi/4.0.6
#  2) gmp/6.2.1     4) mpc/1.1.0    6) zlib/1.2.11   8) cuda/11.4.2


# 3. clone llama.cpp locally
git clone https://github.com/ggerganov/llama.cpp.git

# 4. build it (might take hours)
cd llama.cpp

cmake -B build -DGGML_CUDA=ON
# check this in the output. Should look like this
# Using CUDA architectures: 52;61;70;75;80

# build with (takes hours)
cmake --build build --config Release


#####################################
### HOW TO BUILD llama-cpp-python ###
#####################################
#
# you need this to run gguf models within python
# nothing to do with the fact that you installed
# llama.cpp above. Llama.cpp is needed only for
# quantization. llama-ccp-python is used to run
# GGUF models in python
# a simple "pip install llama-cpp-python" will not
# install the GPU version

# 1. spin the gpu instance
sinteractive -p gpu -N 1 -n 4 -A soc250007-gpu --gres=gpu:1 -t 2:0:0

# 2. load the modules as in the above
module load modtree/gpu   # default gcc and cuda version too old
module load cuda/11  # the version of cuda and gcc shold match on this cluster
module load gcc/11
module load anaconda
module list

# 3. activate the env to have it installed properly

conda activate jago

# 4. build it. Takes forever
CMAKE_ARGS="-DGGML_CUDA=on" pip install llama-cpp-python


####################
### QUANTIZATION ###
####################
# How to quantize llama-3.2-3B with llama.cpp
module load modtree/gpu   # default gcc and cuda version too old
module load cuda/11  # the version of cuda and gcc shold match on this cluster
module load gcc/11
module load anaconda
module list
# Currently Loaded Modules:
#  1) modtree/gpu   3) mpfr/4.0.2   5) gcc/11.2.0    7) numactl/2.0.14   9) openmpi/4.0.6
#  2) gmp/6.2.1     4) mpc/1.1.0    6) zlib/1.2.11   8) cuda/11.4.2     10) anaconda/2021.05-py38

conda activate jago

huggingface-cli download meta-llama/Llama-3.2-3B --include "*" --local-dir Llama-3.2-3B

/home/x-siacus/llama.cpp/convert_hf_to_gguf.py Llama-3.2-3B \
 --outfile Llama-3.2-3B-f16.gguf \
  --outtype f16

/home/x-siacus/llama.cpp/build/bin/llama-quantize Llama-3.2-3B-f16.gguf \
    Llama-3.2-3B-Q4_K_M.gguf  Q4_K_M  

/home/x-siacus/llama.cpp/convert_hf_to_gguf.py Llama-3.2-3B-Instruct \
 --outfile Llama-3.2-3B-Instruct-f16.gguf \
  --outtype f16

/home/x-siacus/llama.cpp/build/bin/llama-quantize Llama-3.2-3B-Instruct-f16.gguf \
    Llama-3.2-3B-Instruct-Q4_K_M.gguf  Q4_K_M  

### END quantize llama

### /home/x-siacus/.conda/envs/jago/lib/python3.10/

# # use this one
# the next script needs this package
# pip install sentencepiece


llama.cpp/convert_hf_to_gguf.py  models/Llama-32-3B-migTest-en \
    --outfile gguf/llama32-3B-migTest-en-f16.gguf \
    --outtype f16

# # 4bit quantization
llama.cpp/build/bin/llama-quantize gguf/llama32-3B-migTest-en-f16.gguf \
    gguf/llama32-3B-migTest-en-Q4_K_M.gguf  Q4_K_M  

# # 4bit quantization
# ~/github/llama.cpp/llama-quantize llama32-3B-migTest-en-f16.gguf \
#     llama32-3B-migTest-en-Q4_K_M.gguf  Q4_K_M  

# llama.cpp/build/bin/llama-simple -m gguf/llama32-3B-migTest-en-Q4_K_M.gguf -n 10 -p "What is the capital of Australia?"


# to go back from GGUF to HF
# https://huggingface.co/docs/transformers/en/gguf
#
# pip install GGUF
from transformers import AutoTokenizer, AutoModelForCausalLM

model_id = "local/Llama-32-3B-migTest-en"
filename = "llama32-3B-migTest-en-f16.gguf"  # move this file under the dir model_id
# remove  "_name_or_path": "meta-llama/Llama-3.2-3B-Instruct",
# from the config.json file of the model_id

tokenizer = AutoTokenizer.from_pretrained(model_id)
model = AutoModelForCausalLM.from_pretrained(model_id, gguf_file=filename)


