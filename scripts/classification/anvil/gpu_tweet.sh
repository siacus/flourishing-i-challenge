#!/bin/bash

# ./gpu_tweet_usa.sh 2023 3 '00:10:00'
# SBATCH script to be executed
SBATCH_SCRIPT="process_classify.sbatch"

# Source directory for .csv.gz files
TWEET_DIR="/anvil/projects/x-soc250007/tweets_us_census"

# General log directory within geotweets
LOG_DIR="/anvil/scratch/x-siacus/log"
FILES_COMPLETED_LOG="${LOG_DIR}/files_completed.txt"

# Directories for stdout and stderr
STDOUT_DIR="${LOG_DIR}/tweets_USA"
STDERR_DIR="${LOG_DIR}/tweets_USA"

# Ensure log directories exist
mkdir -p "${LOG_DIR}" "${STDOUT_DIR}" "${STDERR_DIR}"

# Ensure the completed log file exists
touch "${FILES_COMPLETED_LOG}"

# Year, number of jobs, and time limit to process (required)
YEAR_TO_PROCESS=$1
NUM_JOBS=$2
TIME_LIMIT=$3

if [[ -z "$YEAR_TO_PROCESS" || -z "$NUM_JOBS" || -z "$TIME_LIMIT" ]]; then
    echo "Usage: bash gpu_tweet_usa.sh <year> <num_jobs> <time_limit>"
    exit 1
fi

echo "Starting job submission for year: $YEAR_TO_PROCESS, num_jobs: $NUM_JOBS, time_limit: $TIME_LIMIT"

# Load completed files into an associative array for fast lookup
declare -A COMPLETED_FILES
while IFS= read -r line; do
    COMPLETED_FILES["$line"]=1
done < "$FILES_COMPLETED_LOG"

# Determine files to process
declare -a FILES
mapfile -t FILES < <(find "${TWEET_DIR}/${YEAR_TO_PROCESS}" -type f -name "${YEAR_TO_PROCESS}-*.parquet" | sort)

# Ensure files are found
if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "No files found for the specified criteria. Exiting."
    exit 1
fi

# Filter out completed files before job submission
declare -a FILES_TO_PROCESS
for FILE in "${FILES[@]}"; do
    if [[ -z "${COMPLETED_FILES[$FILE]}" ]]; then
        FILES_TO_PROCESS+=("$FILE")
    else
        echo "Skipping completed file: $FILE"
    fi
done

# Ensure there are files left to process
if [[ ${#FILES_TO_PROCESS[@]} -eq 0 ]]; then
    echo "All files for the selected year have already been processed. Exiting."
    exit 0
fi

# Counter for jobs submitted
JOB_COUNT=0

# Loop through remaining files and submit jobs
for FILE in "${FILES_TO_PROCESS[@]}"; do
    BASENAME=$(basename "$FILE")

    # Print filename as a progress indicator
    echo "Submitting job for ${BASENAME}"

    # Submit the SLURM job and capture the job ID
    JOB_ID=$(sbatch --requeue --time=${TIME_LIMIT} --job-name=${BASENAME} --output=${STDOUT_DIR}/${BASENAME}.log --error=${STDERR_DIR}/${BASENAME}.log ${SBATCH_SCRIPT} "${FILE}" | awk '{print $4}')
    
    echo "Current job id: ${JOB_ID}"
    
    # Increment job count and check if max jobs reached
    ((JOB_COUNT++))
    if [[ $JOB_COUNT -ge $NUM_JOBS ]]; then
        echo "Reached the maximum number of jobs (${NUM_JOBS}). Exiting."
        break
    fi
    
    # Sleep briefly to be kind to the scheduler
    sleep 1
done
