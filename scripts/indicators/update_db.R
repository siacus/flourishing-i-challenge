# (c) SMI 2025
# salloc -p test  --ntasks=1 --cpus-per-task=8 --mem=64G -t 120

rm(list=ls())

# Load necessary packages
if(!require(RSQLite)) install.packages("RSQLite")
if(!require(DBI)) install.packages("DBI")
if(!require(lubridate)) install.packages("lubridate")

# Directories
PK_DIR <- "/n/netscratch/siacus_lab/Lab/output/"
DB_DIR <- "/n/home11/siacus/siacus_lab/Users/siacus"
db_path <- file.path(DB_DIR, "parquet_files.db")

# Safe DB connect with retry on lock
safe_db_connect <- function(db_path, retries = 50, wait_sec = 2) {
  for (i in seq_len(retries)) {
    result <- tryCatch({
      con <- dbConnect(SQLite(), dbname = db_path)
      return(con)
    }, error = function(e) {
      if (grepl("locked", e$message)) {
        Sys.sleep(wait_sec)
        return(NULL)
      } else stop(e)
    })
    if (!is.null(result)) return(result)
  }
  stop("Could not connect to DB after retries due to lock.")
}

# Ensure DB directory exists
if (!dir.exists(DB_DIR)) dir.create(DB_DIR, recursive = TRUE)

# Connect and ensure file_status table exists
con <- safe_db_connect(db_path)
dbExecute(con, "
  CREATE TABLE IF NOT EXISTS file_status (
    filename TEXT PRIMARY KEY,
    status TEXT,
    counts INTEGER
  )")

# Get list of existing filenames in DB
existing <- dbGetQuery(con, "SELECT filename FROM file_status")$filename

# List all .parquet files
parquet_files <- list.files(PK_DIR, pattern = "\\.parquet$", full.names = FALSE)

# Filter only new files
new_files <- setdiff(parquet_files, existing)

# Insert only new ones
if (length(new_files) > 0) {
  data_to_insert <- data.frame(
    filename = new_files,
    status = "waiting",
    counts = NA_integer_,
    stringsAsFactors = FALSE
  )
  tryCatch({
    dbWriteTable(con, "file_status", data_to_insert, append = TRUE, row.names = FALSE)
    cat("Inserted", nrow(data_to_insert), "new files into file_status.\n")
  }, error = function(e) {
    warning("Failed to write new files: ", e$message)
  })
} else {
  cat("No new files to insert.\n")
}

dbDisconnect(con)

y <- substr(parquet_files,1, 10)
y <- c(y, substr(new_files,1, 10))
y <- as.Date(y)
table(year(y))

distinct_days_per_year <- tapply(y, year(y), function(x) length(unique(x)))
distinct_days_per_year_df <- data.frame(
  year = as.numeric(names(distinct_days_per_year)),
  distinct_days = as.numeric(distinct_days_per_year)
)

print(distinct_days_per_year_df)

cat("Update complete.\n")
