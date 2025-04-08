#!/bin/bash
# (c) SMI 2025

# ./indicators_usa.sh  50 '71:59:59'
# ./indicators_usa.sh  10 '23:59:59'
# max 3 days
#### scancel -u $USER

SBATCH_SCRIPT="indicators_USA-fasrc.sbatch"


# General log directory within geotweets
LOG_DIR="/n/netscratch/siacus_lab/Lab/logs/" # FASRC

# Directories for stdout and stderr
STDOUT_DIR="${LOG_DIR}/analysis_USA"
STDERR_DIR="${LOG_DIR}/analysis_USA"

# Ensure log directories exist
mkdir -p "${LOG_DIR}" "${STDOUT_DIR}" "${STDERR_DIR}"

echo "Starting job submission..."

NUM_JOBS=$1
TIME_LIMIT=$2
# Counter for jobs submitted
JOB_COUNT=0

# Loop through remaining files and submit jobs
for (( i=1; i<=NUM_JOBS; i++ )); do
    HEX=$(openssl rand -hex 3)  # 3 bytes = 6 hex characters
    BASENAME="indicators_${HEX}"
    
    echo "Submitting job ${i} as ${BASENAME}"

    JOB_ID=$(sbatch --requeue --time=${TIME_LIMIT} \
        --job-name=${BASENAME} \
        --output=${STDOUT_DIR}/${BASENAME}.log \
        --error=${STDERR_DIR}/${BASENAME}.log \
        ${SBATCH_SCRIPT} | awk '{print $4}')

    echo "Current job id: ${JOB_ID}"

    ((JOB_COUNT++))
    if [[ $JOB_COUNT -ge $NUM_JOBS ]]; then
        echo "Reached the maximum number of jobs (${NUM_JOBS}). Exiting."
        break
    fi

    sleep 1
done

