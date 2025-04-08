# classification script
# (c) SMI 2025

import os
import time
import pandas as pd
from tqdm import tqdm
from datasets import load_dataset
from llama_cpp import Llama
import re
import ast
import subprocess
import sys
from datetime import datetime
import glob
import psutil  # To check CPU memory

batch_size = 250 

scratch = "/anvil/scratch/x-siacus"
log_dir = os.path.join(scratch, "log") # log dir
out_dir = os.path.join(scratch, "output") # output dir, where to save classifications
gguf_dir = os.path.join(scratch, "gguf") # the directory that conain the quantized LLMs

# Creates necessary directories
os.makedirs(log_dir, exist_ok=True) # Creates log dir
os.makedirs(out_dir, exist_ok=True) # Creates output dir

FAILED_LOG_FILE = os.path.join(log_dir, "files_failed2load.csv")
FILES_COMPLETED_LOG = os.path.join(log_dir, "files_completed.txt")




if len(sys.argv) < 2:
    print("Usage: python classify-batch.py <parquet_file>")
    sys.exit(1)

# We try to load the data before loading the models in GPU
parquet_file = sys.argv[1]

  
try:
    df = pd.read_parquet(parquet_file)
    df = pd.DataFrame(df)
except Exception as e:
    log_df = pd.DataFrame([[parquet_file, str(e)]], columns=['file', 'error'])
    log_df.to_csv(FAILED_LOG_FILE, mode='a', header=not os.path.exists(FAILED_LOG_FILE), index=False)
    sys.exit(1)

# Select only required columns
expected_columns = ['message_id', 'date', 'text', 'tweet_lang', 'retweets', 'tweet_favorites', 
                    'GEOID20', 'UR20', 'UACE20', 'UATYPE20', 'latitude', 'longitude', 'user_id']

# Ensure missing columns don't break the script
df = df[[col for col in expected_columns if col in df.columns]]
# Drop rows with missing essential values
df = df.dropna(subset=['text', 'message_id', 'date', 'GEOID20'])
# Fill missing values for categorical columns
df.fillna(value={'UACE20': 'R', 'UATYPE20': 'R'}, inplace=True)
# Convert all columns to string to avoid type mismatches
df = df.astype(str)
df = df.reset_index(drop=True)

print(f"\nData loaded from '{parquet_file}' succesfully loaded, {df.shape[0]} rows\n")

# Define models' paths
mod_SWB = "llama32-3B-swb-100-fasrc-Q4_K_M.gguf"
mod_COR = "llama32-3B-corruption-100-fasrc-Q4_K_M.gguf"
mod_MIG = "llama32-3B-mig-en-es-full-Q4_K_M.gguf"
mod_SWB_path = os.path.join(gguf_dir, mod_SWB)
mod_COR_path = os.path.join(gguf_dir, mod_COR)
mod_MIG_path = os.path.join(gguf_dir, mod_MIG)



def check_memory():
    """Check GPU memory if available; otherwise, check CPU memory."""
    # Try checking GPU memory using nvidia-smi
    try:
        result = subprocess.run(
            ["nvidia-smi", "--query-gpu=memory.used,memory.total", "--format=csv,noheader,nounits"],
            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, check=True
        )
        gpu_memory = result.stdout.strip().split("\n")
        for i, mem in enumerate(gpu_memory):
            used, total = map(int, mem.split(", "))
            print(f"GPU {i}: {used} MB / {total} MB used")
        return used, total
    except (subprocess.CalledProcessError, FileNotFoundError):
        # No GPU found, fallback to CPU memory check
        batch_size = 50 # we also reduce batch size to save more results
        mem = psutil.virtual_memory()
        used, total = mem.used // (1024 * 1024), mem.total // (1024 * 1024)
        print(f"CPU Memory: {used} MB / {total} MB used")
        return used, total

# Example usage
check_memory()

print("Loading models...")

# Load LLaMA model with optimized settings
llm_SWB = Llama(
    model_path=mod_SWB_path, 
    n_ctx=4096,  # Large context window
    n_gpu_layers=-1,  # Full GPU offloading
    #n_batch=512,  # Optimized batch size for A100
    verbose=False
)

llm_COR = Llama(
    model_path=mod_COR_path,
    n_ctx = 4096,
    n_gpu_layers = -1,
    #n_batch=512,
    verbose=False
)

llm_MIG = Llama(
    model_path=mod_MIG_path,
    n_ctx = 2048,
    n_gpu_layers = -1,
    #n_batch=512,
    verbose=False
)

print("Models loaded successfully on memory.")
check_memory()

  

# PROMPTS

# PROMPT: SWB
mappingSWB = pd.read_csv("mappingSWB.csv")
cat_list_SWB = ", ".join([f"C{row['numCat']} = '{row['cat']}'" for _, row in mappingSWB.iterrows()])
cat_list_SWB = f"[ {cat_list_SWB} ]"
instructionSystem_SWB = """You are a medical professional expert in subjective well-being. Answer the question truthfully."""
instruction_SWB = f"""Please classify the following text based on the well-being dimensions listed below. Use only the scale: 'low', 'medium', and 'high'. Return a JSON dictionary that contains only the well-being dimensions that apply. Do not explain your reasoning.\n
Well-being dimensions:\n{cat_list_SWB}"""

# PROMPT: COR
instructionSystem_COR = """You are an expert on corruption issues. Answer the question truthfully."""
instruction_COR = f"""I'm studying perception of corruption. Here is a tweet:"""
questions_COR = """I have five questions you need to answer.

Q1: Is the tweet about corruption? : 1 = yes, 2 = no.

Q2: Does the tweet: 1 = express distrust in governmental or judicial institutions; 2 = mention specific leaders or organizations to be blamed; 3 = it is not about corruption. Answer with a number. Do not give a textual explanation.

Q3: Does the tweet: 1 = describe personal experiences with corruption; 2 = reflect broader societal issues, such as inequality or governance problems; 3 = it is not about corruption. Answer with a number. Do not give a textual explanation.

Q4: Does the tweet: report any specific type of corruption? 1 = generic corruption, 2 = Bribery, 3 = Fraud, 4 = Nepotism, 5 = Abuse of power, 6 = Conflict of interest, 7 = Money laundering, 8 = Tax evasion, 9 = Insider trading, 10 = Corporate fraud, 11 = Police corruption, 12 = Judicial corruption, 13 = Extortion, 14 = Cover-up,  15 = Whistleblower, 16 = not about corruption. Answer with a number or a sequence of numbers separated by commas. Do not give a textual explanation. 

Q5: Are emotions such as anger, frustration, or distrust prevalent? 1 = yes, 2 = no. Answer with a number. Do not give a textual explanation.

Q6: Does the tweets reflect narratives shaped by news outlets? 1 = yes, 2 = no.

Use the following template: 

Q1 = [your answer];
Q2 = [your answer];
Q3 = [your answer];
Q4 = [your answer];
Q5 = [your answer];
Q6 = [your answer].
"""

# PROMPT: MIG
instructionSystem_MIG = """You are an expert on migration. Answer the question truthfully."""
instruction_MIG = f"""The next text is a tweet probably about migration"""
categories_MIG = ["pro-immigration",  "anti-immigration",  "neutral", "unrelated"] 
catcodes_MIG = [1, 2, 3, 4]
catDict_MIG = dict(zip(categories_MIG, catcodes_MIG))
hint_MIG = result_string = "; ".join(f"{v} = '{k}'" for k, v in catDict_MIG.items())


# QUERIES

# QUERY: SWB
def create_Query_SWB(tweet):
    return f"""<|start_header_id|>system<|end_header_id|> {instructionSystem_SWB} <|eot_id|><|start_header_id|>user<|end_header_id|> {instruction_SWB}.
Here is the text:"{tweet}".<|eot_id|><|start_header_id|>assistant<|end_header_id|> Answer :"""

# QUERY: COR
def create_Query_COR(tweet):
    tmp = f"""<|start_header_id|>system<|end_header_id|> {instructionSystem_COR} <|eot_id|><|start_header_id|>user<|end_header_id|>{instruction_COR}:"{tweet}"\n{questions_COR}<|eot_id|><|start_header_id|>assistant<|end_header_id|>Answer:"""
    return tmp

# QUERY: MIG
def create_Query_MIG(tweet):
    tmp = f"""<|start_header_id|>system<|end_header_id|> {instructionSystem_MIG} <|eot_id|><|start_header_id|>user<|end_header_id|>{instruction_MIG}:"{tweet}"\nAnalyze carefully the tweet and assign it to the most relevant category among those listed below. Do not explain your answer and return only a number.\nCategory numbers: {hint_MIG}.<|eot_id|><|start_header_id|>assistant<|end_header_id|>Answer ="""
    return tmp


# EXTRACTORS

# SWB
def extract_dict_SWB(text):
    try:
        text = text.strip()
        match = re.search(r"\{[^{}]*\}", text)
        if match:
            return ast.literal_eval(match.group(0))
        return {}
    except (SyntaxError, ValueError):
        return {}

def get_SWB(text, marker="Answer :"):
    start_index = text.find(marker)
    if start_index != -1:
        relevant_text = text[start_index + len(marker):]
    else:
        # If the marker is not found, return an empty DataFrame
        return pd.DataFrame(columns=['dimension', 'value'])
    return pd.DataFrame(list(extract_dict_SWB(relevant_text).items()), columns=['dimension', 'value'])


# COR
def get_COR(text, marker="Answer:"):
    start_index = text.find(marker)
    if start_index != -1:
        relevant_text = text[start_index + len(marker):]
    else:
        # If the marker is not found, return an empty DataFrame
        return pd.DataFrame(columns=["Question", "Answer"])
    pattern = r"(Q[1-6]) = ([^\n;]+)[;]?"
    matches = re.findall(pattern, relevant_text)
    df = pd.DataFrame(matches, columns=["Question", "Answer"])
    df["Answer"] = df["Answer"].apply(lambda x: re.sub(r"[.,;]", " ", x).replace(",", " "))
    transformed = df.set_index('Question').T
    transformed = transformed.map(lambda x: re.sub(r"[\[\]]", "", str(x)) if isinstance(x, str) else x)
    transformed = transformed.reset_index(drop=True)
    return transformed

# MIG
def get_MIG(answer):
    match = re.search(r'Answer =.*?(\d+)', answer)
    if match:
        return int(match.group(1))
    else:
        return(0)


# ASK LLMs

def askLLM_SWB(tweet):
    retries = 1
    temperature = 0
    query = create_Query_SWB(tweet)
    response = None
    while retries < 5:
        output = llm_SWB(query, max_tokens=400, echo=True, temperature=0, stop=["}"])
        answer = output['choices'][0]['text'] + "}"
        response = get_SWB(answer)
        if response.shape[0]>0:
                break
        retries += 1
        temperature += 0.05
    columns = [f'C{i}' for i in range(1, 47)]
    row_df = pd.DataFrame(columns=columns)
    # Populating the transformed DataFrame
    row_data = {col: "" for col in columns}  # Default values as empty strings
    if response.shape[0]>0:
        for _, row in response.iterrows():
            row_data[row['dimension']] = row['value']
        row_df = pd.DataFrame([row_data])
    return(row_df)

def askLLM_COR(tweet):
    retries = 1
    temperature = 0
    query = create_Query_COR(tweet)
    response = None
    while retries < 5:
        output = llm_COR(query, max_tokens=100, echo=True, temperature = 0)
        answer = output['choices'][0]['text']
        response = get_COR(answer)
        if response.shape[0]>0:
                break
        retries += 1
        temperature += 0.05
    return(response)

def askLLM_MIG(tweet):
    retries = 1
    temperature = 0
    query = create_Query_MIG(tweet)
    response = None
    while retries < 5:
        output = llm_MIG(query, max_tokens=5, echo=True, temperature = temperature)
        answer = output['choices'][0]['text']
        response = get_MIG(answer)
        if response in [1, 2, 3, 4]:
                break
        retries += 1
        temperature += 0.05 
    response = pd.DataFrame([response], columns=["Migmood"])
    return(response)


# Process dataset using batch inference
fname = os.path.basename(parquet_file)
fname = os.path.splitext(fname)[0] 
output_file = fname + "_out.csv"
#output_file = os.path.splitext(output_file)[0] + "_out.parquet"
output_file = os.path.join(scratch, "output", output_file)
if os.path.exists(output_file):
    os.remove(output_file)


fname = os.path.basename(parquet_file)
fname = os.path.splitext(fname)[0] 

def get_last_batch(fname):
    search_pattern = os.path.join(out_dir, f"{fname}*.parquet")
    filenames = [os.path.basename(file) for file in glob.glob(search_pattern)]
    batch_numbers = []
    for filename in filenames:
        # Remove .parquet extension
        name_without_ext = filename.replace(".parquet", "")
        # Extract batch numbers after "batch_"
        match = re.search(r"batch_(\d+)_(\d+)", name_without_ext)
        if match:
            batch_numbers.append(int(match.group(2)))  # Extract the second number in the range
    # Find the maximum batch number
    return max(batch_numbers) if batch_numbers else 0

restart_batch = get_last_batch(fname) 

texts = df['text']
ids = df['message_id']
n = len(texts)
current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
print(f"\nStarting on {current_time}\nRestarting from text {restart_batch}\n")

if restart_batch >= n:
    print(f"File {parquet_file} completed!")
    with open(FILES_COMPLETED_LOG, "a") as comp_file:
                comp_file.write(f"{parquet_file}\n")

start_time = time.time()
for batch_start in tqdm(range(restart_batch, n, batch_size), desc="Processing batches"):
    try:
        print(f"Start = {batch_start}")
        batch = texts[batch_start: batch_start + batch_size]
        batch_ids = ids[batch_start: batch_start + batch_size]
        batch_ids_reset = batch_ids.reset_index(drop=True)
        print("doing SWB")
        batch_SWB = [askLLM_SWB(text) for text in batch]
        print("end SWB")
        batch_SWB = pd.concat(batch_SWB, ignore_index=True)
        batch_SWB['id'] = batch_ids_reset   
        print("doing COR")
        batch_COR = [askLLM_COR(text) for text in batch]
        print("end COR")
        batch_COR = pd.concat(batch_COR, ignore_index=True)
        batch_COR['id'] = batch_ids_reset   
        print("doing MIG")
        batch_MIG = [askLLM_MIG(text) for text in batch]
        print("end MIG")
        batch_MIG = pd.concat(batch_MIG, ignore_index=True)
        batch_MIG['id'] = batch_ids_reset
        merged_df = batch_MIG.merge(batch_COR, on='id', how='outer').merge(batch_SWB, on='id', how='outer')
        merged_df = merged_df.fillna("")
        tmp = df.iloc[batch_start: batch_start + batch_size].copy()
        tmp.rename(columns={'message_id': 'id'}, inplace=True)
        final_df = merged_df.merge(tmp, on='id', how='outer')
        final_df = final_df.fillna("")
        column_order = ['id'] + [col for col in final_df.columns if col != 'id']
        final_df = final_df[column_order]
        final_df.rename(columns={'id': 'message_id'}, inplace=True)
        start = batch_start
        end = batch_start+batch_size
        batch_output_file = os.path.join(scratch, "output", f"{fname}_batch_{start}_{end}.parquet")
        print(batch_output_file)
        final_df.to_parquet(batch_output_file, index=False)
    except Exception as e:
        print(f"Error processing batch starting at index {batch_start}: {e}")

end_time = time.time()
print(f"Time spent running the code: {end_time - start_time:.2f} seconds")


