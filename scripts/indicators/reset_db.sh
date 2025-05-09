#!/bin/bash
# (c) SMI 2025

# ./reset_db.sh '5:59:59'
#### scancel -u $USER

SBATCH_SCRIPT="reset_db-fasrc.sbatch"


# General log directory within geotweets
LOG_DIR="/n/netscratch/siacus_lab/Lab/logs/" # FASRC

# Directories for stdout and stderr
STDOUT_DIR="${LOG_DIR}/analysis_USA"
STDERR_DIR="${LOG_DIR}/analysis_USA"

# Ensure log directories exist
mkdir -p "${LOG_DIR}" "${STDOUT_DIR}" "${STDERR_DIR}"

echo "Starting job submission..."

TIME_LIMIT=$1
# Counter for jobs submitted

# Loop through remaining files and submit jobs
HEX=$(openssl rand -hex 3)  # 3 bytes = 6 hex characters
BASENAME="reset_db_${HEX}"
echo "Submitting job ${i} as ${BASENAME}"
JOB_ID=$(sbatch --requeue --time=${TIME_LIMIT} \
        --job-name=${BASENAME} \
        --output=${STDOUT_DIR}/${BASENAME}.log \
        --error=${STDERR_DIR}/${BASENAME}.log \
        ${SBATCH_SCRIPT} | awk '{print $4}')

echo "Current job id: ${JOB_ID}"

