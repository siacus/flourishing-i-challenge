# # reads parquet files and creates indicators
# (c) SMI 2025
# Rscript generate_indicators.R > indlog.txt 2>&1 &
# module load R

# salloc -p shared  --ntasks=1 --cpus-per-task=8 --mem=32G -t 120
# salloc -p test  --ntasks=1 --cpus-per-task=16 --mem=64G -t 120

rm(list=ls())

# Load necessary packages
if(!require(RSQLite)) install.packages("RSQLite")
if(!require(DBI)) install.packages("DBI")
if(!require(arrow)) install.packages("arrow")
if(!require(progress)) install.packages("progress")

batch_size <- 10000

# Directories
PK_DIR="/n/netscratch/siacus_lab/Lab/output/" # FASRC
DB_DIR = '/n/home11/siacus/siacus_lab/Users/siacus'
stats_db_path <- file.path(DB_DIR, "stats-mid.db")


swbMapping <- read.csv("/n/home11/siacus/siacus_lab/Users/siacus/all/mappingSWB.csv", stringsAsFactors = FALSE)

# Create shortened SQL-safe one-word labels (manually defined)
labels <- c(
  "happiness", "resilience", "selfesteem", "lifesat", "fearfuture", "vitality",
  "energy", "posfunct", "jobsat", "optimism", "innerpeace", "purpose",
  "depression", "anxiety", "suffering", "pain", "altruism", "loneliness",
  "relationships", "belonging", "gratitude", "trust", "trusted", "balance",
  "mastery", "discrim", "lovedgod", "believegod", "relcrit", "spiritpun",
  "relcomfort", "finworry", "afterlife", "volunteer", "charity", "forgive",
  "polvoice", "govapprove", "hope", "goodpromo", "delaygrat", "ptsd",
  "smokehealth", "drinkhealth", "healthlim", "empathy"
)

# Assign category codes like C1, C2, ..., C46
swbMapping$numCat <- paste0("C", seq_len(nrow(swbMapping)))

# Assign labels
swbMapping$label <- labels

# Connect to (or create) SQLite database
db_path <- file.path(DB_DIR, "parquet_files.db")
Sys.sleep(sample(1:30,1))

all_files <- list.files(DB_DIR, pattern = "^indicators.*\\.db$", full.names = FALSE)
numbered_files <- grep("^indicators[0-9]+\\.db$", all_files, value = TRUE)
existing_ids <- as.integer(gsub("^indicators([0-9]+)\\.db$", "\\1", numbered_files))
existing_ids <- existing_ids[!is.na(existing_ids)]
cat(sprintf("\nExisting IDs: %s\n", paste(sort(existing_ids), collapse = ", ")))
newID <- if (length(existing_ids) == 0) 1 else max(existing_ids) + 1
databasename <- sprintf("indicators%d.db", newID)
indicators_db_path <- file.path(DB_DIR, databasename)
cat(sprintf("Working on db %s\n",databasename))
cat(sprintf("Creating new DB: %s\n", indicators_db_path))
con <- dbConnect(RSQLite::SQLite(), dbname = indicators_db_path)
dbExecute(con, "CREATE TABLE IF NOT EXISTS test (fake TEXT)")
dbDisconnect(con)


claim_batch <- function(batch_size = 1000, max_retries = 50, con = NULL) {
  for (attempt in 1:max_retries) {
    tryCatch({
      # Begin immediate transaction (fails if DB is locked)
      dbExecute(con, "BEGIN IMMEDIATE")
      dbExecute(con, "DROP TABLE IF EXISTS temp_claim")
      # Create a temporary table with rowids to update
      dbExecute(con, sprintf("
        CREATE TEMP TABLE temp_claim AS
        SELECT rowid FROM file_status
        WHERE status = 'waiting'
        LIMIT %d
      ", batch_size))

      # Update the selected rows to 'processing'
      updated <- dbExecute(con, "
        UPDATE file_status
        SET status = 'processing'
        WHERE rowid IN (SELECT rowid FROM temp_claim)
      ")

      dbExecute(con, "COMMIT")

      if (updated == 0) {
        message("No unclaimed rows left.")
        return(NULL)
      }

      # Get filenames of claimed rows
      files <- dbGetQuery(con, "
        SELECT filename FROM file_status
        WHERE status = 'processing'
        LIMIT ?", params = list(batch_size))
      return(files$filename)

    }, error = function(e) {
      if (grepl("locked", e$message)) {
        retry_delay <- sample(30:100,1)
        message(sprintf("DB is locked, retrying in %d seconds... (%d/%d)", retry_delay, attempt, max_retries))
        Sys.sleep(retry_delay)
      } else {
        stop(e)
      }
    })
  }

  message("Failed to claim rows after multiple retries.")
  return(NULL)
}

dbcon <- dbConnect(SQLite(), dbname = db_path)
file_list <- claim_batch(con=dbcon, batch_size=batch_size)
dbDisconnect(dbcon)

# Initialize progress bar
if(length(file_list) == 0) {
  cat("\nNo files to process.\n")
  if (file.exists(indicators_db_path)) {
    file.remove(indicators_db_path)
  }
  quit()
}


migScale <- function(x) {
    mapping <- c(1L, -1L, 0L, 4L)
    mapping[mapping==4] <- NA_integer_
    unname(mapping[x])
}
swbScale <- function(x) {
    x[x == ""] <- NA  # Convert empty strings to NA
    mapping <- c("low" = -1, "medium" = 0.5, "high" = 1)
    unname(mapping[x])
}

# Chunked queries to handle SQLite limitations
chunked_query <- function(filenames, query_template, chunk_size = 900) {
  n <- length(filenames)
  chunks <- split(filenames, ceiling(seq_len(n) / chunk_size))
  queries <- lapply(chunks, function(chunk) {
    placeholders <- paste(sprintf("'%s'", chunk), collapse = ", ")
    sprintf(query_template, placeholders)
  })
  return(queries)
}

safe_db_batch_update <- function(update_df, db_path, retries = 50, wait_sec = 2, chunk_size = 500) {
  if (nrow(update_df) == 0) return()

  chunks <- split(update_df, ceiling(seq_len(nrow(update_df)) / chunk_size))

  for (chunk_df in chunks) {
    for (i in seq_len(retries)) {
      con <- dbConnect(SQLite(), dbname = db_path)
      result <- tryCatch({
        filenames <- chunk_df$filename

        case_counts <- paste0(
          "WHEN filename = '", filenames, "' THEN ",
          ifelse(is.na(chunk_df$counts), "NULL", chunk_df$counts)
        )
        case_status <- paste0(
          "WHEN filename = '", filenames, "' THEN '", chunk_df$status, "'"
        )
        in_clause <- paste(sprintf("'%s'", filenames), collapse = ", ")

        sql <- sprintf("
          UPDATE file_status SET
            counts = CASE %s ELSE counts END,
            status = CASE %s ELSE status END
          WHERE filename IN (%s)",
          paste(case_counts, collapse = " "),
          paste(case_status, collapse = " "),
          in_clause
        )

        dbExecute(con, sql)
        dbDisconnect(con)
        cat("!")
        return(TRUE)
      }, error = function(e) {
        dbDisconnect(con)
        cat("x")
        if (grepl("locked", e$message)) {
          Sys.sleep(wait_sec)
          return(FALSE)
        } else {
          stop(e)
        }
      })

      if (isTRUE(result)) break
    }
  }
}


safe_db_write_table <- function(db_path, table_name, data, retries = 50, wait_sec = 2) {
  for (i in seq_len(retries)) {
    con <- dbConnect(SQLite(), dbname = db_path)
    result <- tryCatch({
      dbWriteTable(con, table_name, data, append = TRUE, row.names = FALSE)
      dbDisconnect(con)
      cat("o")
      return(TRUE)
    }, error = function(e) {
      dbDisconnect(con)
      cat("X")
      if (grepl("locked", e$message)) {
        Sys.sleep(wait_sec)
        return(FALSE)
      } else {
        stop(e)
      }
    })
    if (isTRUE(result)) break
  }
}

final_status_check <- function(file_list, db_path) {
  con <- dbConnect(SQLite(), dbname = db_path)
  on.exit(dbDisconnect(con))

  query_template <- "SELECT filename FROM file_status WHERE status = 'processing' AND filename IN (%s)"
  queries <- chunked_query(file_list, query_template)

  stuck_files <- character()
  for (query in queries) {
    res <- dbGetQuery(con, query)$filename
    stuck_files <- c(stuck_files, res)
  }

  if (length(stuck_files) > 0) {
    cat("Found", length(stuck_files), "files still in 'processing'. Resetting to 'waiting'.\n")
    
    # Again, chunk updates
    update_chunks <- split(stuck_files, ceiling(seq_along(stuck_files)/900))
    
    for (chunk in update_chunks) {
      safe_db_batch_update(
        data.frame(filename = chunk, counts = NA_integer_, status = 'waiting'),
        db_path
      )
    }
  } else {
    cat("All files processed successfully (status updated).\n")
  }
}

pb <- progress::progress_bar$new(
  format = "[:bar] :current/:total (:percent) ETA: :eta",
  total = length(file_list), clear = FALSE, width = 60
)

num_files <- length(file_list)
batch_size <- min(500,  ceiling(num_files/10))
batches <- split(file_list, ceiling(seq_along(file_list) / batch_size))
tot <- 0

sanitize <- function(v){
      n <- nrow(v)
      if(ncol(v)>1){
        v <- apply(v, 2, function(u) ifelse(u=="", NA, u))
        check <- apply(v, 2, function(u) sum(is.na(u))==0 )
        v <- v[,check, drop=FALSE]
        if(ncol(v)==0){
          v <- rep(NA_character_, n)
        }
      }
      return(as.vector(v[,1]))
}

for (batch in batches) {
  tot <- tot + length(batch)
  cat(sprintf("\nProcessing batch of %d of %d files, remaining = %d...\n", length(batch), num_files,num_files - tot - length(batch)))  # ← add here

  parquet_list <- list()
  indicators_list <- list()
  success_files <- list()
  failed_files <- list()

  for (file_to_read in batch) {
    file_path <- file.path(PK_DIR, file_to_read)
    tryCatch({
      parquet_data <- read_parquet(file_path)
      parquet_data$filename <- file_to_read
      parquet_data$date <- as.character(as.Date(parquet_data$date))

      idx <- which(duplicated(parquet_data))
      if (length(idx) > 0) {
        parquet_data <- parquet_data[-idx, ]
      }
     
      cols <- colnames(parquet_data)
      indicators <- data.frame(
        date = parquet_data$date,
        GEOID20 =  parquet_data$GEOID20,
        lat = sanitize(parquet_data[,grep("latitude",cols), drop=FALSE]),
        lon = sanitize(parquet_data[,grep("longitude",cols), drop=FALSE]),
        idMsg = sanitize(parquet_data[,grep("message_id",cols), drop=FALSE]),
        idUser = sanitize(parquet_data[,grep("user_id",cols), drop=FALSE]),
        filename = file_to_read,
        migmood = migScale(parquet_data$Migmood),
        corruption = as.integer(sanitize(parquet_data[,grep("Q1",cols), drop=FALSE])),
        stringsAsFactors = FALSE
      )

      # Add SWB columns
      for (i in seq_len(nrow(swbMapping))) {
        colname <- swbMapping$numCat[i]
        newname <- swbMapping$label[i]
        if (colname %in% names(parquet_data)) {
          indicators[[newname]] <- swbScale(parquet_data[[colname]])
        } else {
          warning(paste("Column", colname, "not found in parquet_data"))
        }
      }

      indicators_list[[file_to_read]] <- indicators
      success_files[[file_to_read]] <- nrow(parquet_data)

      cat("\tProcessed:", file_to_read, "- Rows:", nrow(parquet_data), "\n")
    }, error = function(e) {
      failed_files[[file_to_read]] <- TRUE
      cat("\tFailed:", file_to_read, "\nError:", conditionMessage(e), "\n")
    })
    pb$tick()
  }

  # Combine and write to indicators DB
  if (length(indicators_list) > 0) {
    cat("\nWriting indicators...\n")
    indicators_batch <- do.call(rbind, indicators_list)
    safe_db_write_table(indicators_db_path, "indicators", indicators_batch)
  }

  # Batch update file_status for processed files
  cat("Updating file_status...\n")

  fail_df <- data.frame(filename = character(), counts = integer(), status = character(), stringsAsFactors = FALSE)
  success_df <- data.frame(filename = character(), counts = integer(), status = character(), stringsAsFactors = FALSE)

  # Build update table
  if(length(success_files)>0){
    success_df <- data.frame(
      filename = names(success_files),
      counts = as.integer(unlist(success_files)),
      status = "done",
      stringsAsFactors = FALSE
    )
  }

  if(length(failed_files)>0){
    fail_df <- data.frame(
      filename = names(failed_files),
      counts = NA_integer_,
      status = "failed",
      stringsAsFactors = FALSE
    )
  }

  update_df <- rbind(success_df, fail_df)
  safe_db_batch_update(update_df, db_path)
  
}

final_status_check(file_list, db_path)


cat("\nUpdating status")

con_stats <- dbConnect(SQLite(), dbname = stats_db_path)

dbExecute(con_stats, "
  CREATE TABLE IF NOT EXISTS status (
    dbname TEXT PRIMARY KEY,
    n_rows INTEGER NOT NULL,
    checked INTEGER
  )
")


dbExecute(con_stats, sprintf( "INSERT INTO status (dbname, nrows, checked) VALUES ('%s', 0, 0) ON CONFLICT(dbname) DO UPDATE SET nrows = excluded.nrows", databasename))

dbDisconnect(con_stats)


cat("\nFinished!\n")

